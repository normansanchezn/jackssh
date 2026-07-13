import Domain
import Foundation

@MainActor
public protocol PortForwardLifecycleReporting: AnyObject {
    func portForwardStarted(host: Domain.Host, endpoint: PortForwardEndpoint, tunnelDescription: String)
    func portForwardStopped()
}

@MainActor
public final class NoopPortForwardLifecycleReporter: PortForwardLifecycleReporting {
    public init() {}

    public func portForwardStarted(host: Domain.Host, endpoint: PortForwardEndpoint, tunnelDescription: String) {}

    public func portForwardStopped() {}
}

#if os(iOS)
@preconcurrency import ActivityKit
import Shared
import UIKit

extension Activity: @retroactive @unchecked Sendable {}
extension ActivityContent: @retroactive @unchecked Sendable where State: Sendable {}

@MainActor
public final class SystemPortForwardLifecycleReporter: PortForwardLifecycleReporting {
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var activity: Activity<PortForwardActivityAttributes>?
    private var didEnterBackgroundObserver: NSObjectProtocol?
    private var willEnterForegroundObserver: NSObjectProtocol?
    private var activeContext: ActivePortForwardContext?

    public init(notificationCenter: NotificationCenter = .default) {
        didEnterBackgroundObserver = notificationCenter.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.beginBackgroundTaskIfNeeded()
            }
        }

        willEnterForegroundObserver = notificationCenter.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.endBackgroundTask()
            }
        }
    }

    public func portForwardStarted(
        host: Domain.Host,
        endpoint: PortForwardEndpoint,
        tunnelDescription: String
    ) {
        activeContext = ActivePortForwardContext(
            hostID: host.id.uuidString,
            hostName: host.name,
            tunnelDescription: tunnelDescription,
            localPort: endpoint.localPort,
            startedAt: Date()
        )
        beginBackgroundTaskIfNeeded()
        startOrUpdateActivity(status: "Port forwarding")
    }

    public func portForwardStopped() {
        activeContext = nil
        endBackgroundTask()
        endActivity()
    }

    private func beginBackgroundTaskIfNeeded() {
        guard activeContext != nil, backgroundTaskID == .invalid else { return }
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "JackSSH Port Forward") { [weak self] in
            Task { @MainActor in
                self?.endBackgroundTask()
            }
        }
    }

    private func endBackgroundTask() {
        guard backgroundTaskID != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }

    private func startOrUpdateActivity(status: String) {
        guard let activeContext, ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let contentState = activeContext.contentState(status: status)
        Task { @MainActor in
            if let activity {
                await activity.update(ActivityContent(state: contentState, staleDate: nil))
                return
            }

            do {
                activity = try Activity.request(
                    attributes: activeContext.attributes,
                    content: ActivityContent(state: contentState, staleDate: nil),
                    pushType: nil
                )
            } catch {
                activity = nil
            }
        }
    }

    private func endActivity() {
        guard let activity else { return }
        self.activity = nil

        let finalState = activity.content.state
        Task { @MainActor in
            await activity.end(
                ActivityContent(state: finalState, staleDate: nil),
                dismissalPolicy: .immediate
            )
        }
    }
}

private struct ActivePortForwardContext {
    let hostID: String
    let hostName: String
    let tunnelDescription: String
    let localPort: Int
    let startedAt: Date

    var attributes: PortForwardActivityAttributes {
        PortForwardActivityAttributes(hostID: hostID, hostName: hostName)
    }

    func contentState(status: String) -> PortForwardActivityAttributes.ContentState {
        PortForwardActivityAttributes.ContentState(
            hostName: hostName,
            tunnelDescription: tunnelDescription,
            localPort: localPort,
            startedAt: startedAt,
            status: status
        )
    }
}
#else
public typealias SystemPortForwardLifecycleReporter = NoopPortForwardLifecycleReporter
#endif
