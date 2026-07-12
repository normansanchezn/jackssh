import Foundation
import Domain

/// Factories the Hosts feature needs, supplied by the composition root so views
/// never construct use cases or touch Data directly.
@MainActor
public struct HostsDependencies {
    public let makeListViewModel: () -> HostsViewModel
    public let makeEditorViewModel: (Domain.Host?) -> HostEditorViewModel
    public let makeConnectingViewModel: (UUID) -> ConnectingHostViewModel

    public init(
        makeListViewModel: @escaping () -> HostsViewModel,
        makeEditorViewModel: @escaping (Domain.Host?) -> HostEditorViewModel,
        makeConnectingViewModel: @escaping (UUID) -> ConnectingHostViewModel
    ) {
        self.makeListViewModel = makeListViewModel
        self.makeEditorViewModel = makeEditorViewModel
        self.makeConnectingViewModel = makeConnectingViewModel
    }
}
