import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class RemoteFilesViewModel {
    public enum ViewState: Equatable {
        case idle
        case loading
        case loaded([SFTPFileInfo])
        case failed(String)
    }

    public private(set) var path: String
    public private(set) var state: ViewState = .idle

    private let hostID: UUID
    private let loadHosts: LoadHosts
    private let makeDirectoryRepository: @Sendable (Domain.Host) -> RemoteDirectoryRepository

    public init(
        hostID: UUID,
        initialPath: String = "/",
        loadHosts: LoadHosts,
        makeDirectoryRepository: @escaping @Sendable (Domain.Host) -> RemoteDirectoryRepository
    ) {
        self.hostID = hostID
        self.path = initialPath
        self.loadHosts = loadHosts
        self.makeDirectoryRepository = makeDirectoryRepository
    }

    public func load() async {
        state = .loading
        do {
            let hosts = try await loadHosts()
            guard let host = hosts.first(where: { $0.id == hostID }) else {
                state = .failed("Host not found")
                return
            }
            let files = try await ListRemoteDirectory(repository: makeDirectoryRepository(host))(at: path)
            state = .loaded(files)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    public func open(_ file: SFTPFileInfo) async {
        guard file.isDirectory else { return }
        path = file.path
        await load()
    }

    public func goUp() async {
        guard path != "/" else { return }
        path = URL(fileURLWithPath: path).deletingLastPathComponent().path
        if path.isEmpty { path = "/" }
        await load()
    }
}
