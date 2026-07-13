import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class RemoteFilesViewModel {
    public typealias CodeFile = RemoteFilesUIState.CodeFile
    public typealias ViewState = RemoteFilesUIState.ViewState

    public private(set) var uiState: RemoteFilesUIState
    public private(set) var effect: RemoteFilesEffect = .none
    public var path: String { uiState.path }
    public var state: ViewState { uiState.state }
    public var codeFile: CodeFile? { uiState.codeFile }
    public var fileLoadError: String? { uiState.fileLoadError }
    public var isLoadingFile: Bool { uiState.isLoadingFile }
    public var favoriteRoutes: [String] { uiState.favoriteRoutes }

    private let hostID: UUID
    private let initialPath: String
    private let loadHosts: LoadHosts
    private let makeDirectoryRepository: @Sendable (Domain.Host) -> RemoteDirectoryRepository
    private let makeFileRepository: @Sendable (Domain.Host) -> RemoteFileRepository
    private var didResolveInitialPath = false

    public init(
        hostID: UUID,
        initialPath: String = "/",
        loadHosts: LoadHosts,
        makeDirectoryRepository: @escaping @Sendable (Domain.Host) -> RemoteDirectoryRepository,
        makeFileRepository: @escaping @Sendable (Domain.Host) -> RemoteFileRepository
    ) {
        self.hostID = hostID
        self.initialPath = initialPath
        self.uiState = RemoteFilesUIState(path: initialPath)
        self.loadHosts = loadHosts
        self.makeDirectoryRepository = makeDirectoryRepository
        self.makeFileRepository = makeFileRepository
    }

    public func load() async {
        uiState.state = .loading
        do {
            let hosts = try await loadHosts()
            guard let host = hosts.first(where: { $0.id == hostID }) else {
                uiState.state = .failed("Host not found")
                effect = .showError("Host not found")
                return
            }
            uiState.favoriteRoutes = host.favoriteRemotePaths
            if !didResolveInitialPath, initialPath == "/", let favoritePath = host.primaryFavoriteRemotePath {
                uiState.path = favoritePath
            }
            didResolveInitialPath = true
            let files = try await ListRemoteDirectory(repository: makeDirectoryRepository(host))(at: path)
            uiState.state = .loaded(files)
        } catch {
            uiState.state = .failed(error.localizedDescription)
            effect = .showError(error.localizedDescription)
        }
    }

    public func go(to path: String) async {
        let normalized = Self.normalizedPath(path)
        guard !normalized.isEmpty else { return }
        uiState.path = normalized
        didResolveInitialPath = true
        await load()
    }

    public func open(_ file: SFTPFileInfo) async {
        if file.isDirectory {
            uiState.path = file.path
            await load()
        } else {
            await openCodeFile(file)
        }
    }

    public func goUp() async {
        guard path != "/" else { return }
        uiState.path = URL(fileURLWithPath: path).deletingLastPathComponent().path
        if uiState.path.isEmpty { uiState.path = "/" }
        await load()
    }

    public func dismissCodeFile() {
        uiState.codeFile = nil
        uiState.fileLoadError = nil
    }

    private func openCodeFile(_ file: SFTPFileInfo) async {
        guard CodeLanguage.detect(for: file.name) != .plainText else {
            uiState.fileLoadError = "Only source and configuration files can be previewed."
            effect = .showError("Only source and configuration files can be previewed.")
            return
        }
        guard file.size.map({ $0 <= Self.maximumPreviewSize }) ?? true else {
            uiState.fileLoadError = "This file is too large to preview on this device."
            effect = .showError("This file is too large to preview on this device.")
            return
        }

        uiState.isLoadingFile = true
        uiState.fileLoadError = nil
        defer { uiState.isLoadingFile = false }

        do {
            let hosts = try await loadHosts()
            guard let host = hosts.first(where: { $0.id == hostID }) else {
                uiState.fileLoadError = "Host not found"
                effect = .showError("Host not found")
                return
            }
            let data = try await ReadRemoteFile(repository: makeFileRepository(host))(at: file.path)
            guard data.count <= Self.maximumPreviewSize else {
                uiState.fileLoadError = "This file is too large to preview on this device."
                effect = .showError("This file is too large to preview on this device.")
                return
            }
            guard let content = String(data: data, encoding: .utf8) else {
                uiState.fileLoadError = "This file is not UTF-8 text and cannot be previewed."
                effect = .showError("This file is not UTF-8 text and cannot be previewed.")
                return
            }
            uiState.codeFile = CodeFile(file: file, content: content)
            effect = .openedPreview
        } catch {
            uiState.fileLoadError = error.localizedDescription
            effect = .showError(error.localizedDescription)
        }
    }

    public func clearEffect() {
        effect = .none
    }

    private static let maximumPreviewSize = 1_000_000

    private static func normalizedPath(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        return trimmed.hasPrefix("/") ? trimmed : "/\(trimmed)"
    }
}
