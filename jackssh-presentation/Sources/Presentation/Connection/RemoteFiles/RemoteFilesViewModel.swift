import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class RemoteFilesViewModel {
    public struct CodeFile: Identifiable, Equatable {
        public let file: SFTPFileInfo
        public let content: String

        public var id: String { file.path }
    }

    public enum ViewState: Equatable {
        case idle
        case loading
        case loaded([SFTPFileInfo])
        case failed(String)
    }

    public private(set) var path: String
    public private(set) var state: ViewState = .idle
    public private(set) var codeFile: CodeFile?
    public private(set) var fileLoadError: String?
    public private(set) var isLoadingFile = false

    private let hostID: UUID
    private let loadHosts: LoadHosts
    private let makeDirectoryRepository: @Sendable (Domain.Host) -> RemoteDirectoryRepository
    private let makeFileRepository: @Sendable (Domain.Host) -> RemoteFileRepository

    public init(
        hostID: UUID,
        initialPath: String = "/",
        loadHosts: LoadHosts,
        makeDirectoryRepository: @escaping @Sendable (Domain.Host) -> RemoteDirectoryRepository,
        makeFileRepository: @escaping @Sendable (Domain.Host) -> RemoteFileRepository
    ) {
        self.hostID = hostID
        self.path = initialPath
        self.loadHosts = loadHosts
        self.makeDirectoryRepository = makeDirectoryRepository
        self.makeFileRepository = makeFileRepository
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
        if file.isDirectory {
            path = file.path
            await load()
        } else {
            await openCodeFile(file)
        }
    }

    public func goUp() async {
        guard path != "/" else { return }
        path = URL(fileURLWithPath: path).deletingLastPathComponent().path
        if path.isEmpty { path = "/" }
        await load()
    }

    public func dismissCodeFile() {
        codeFile = nil
        fileLoadError = nil
    }

    private func openCodeFile(_ file: SFTPFileInfo) async {
        guard CodeLanguage.detect(for: file.name) != .plainText else {
            fileLoadError = "Only source and configuration files can be previewed."
            return
        }
        guard file.size.map({ $0 <= Self.maximumPreviewSize }) ?? true else {
            fileLoadError = "This file is too large to preview on this device."
            return
        }

        isLoadingFile = true
        fileLoadError = nil
        defer { isLoadingFile = false }

        do {
            let hosts = try await loadHosts()
            guard let host = hosts.first(where: { $0.id == hostID }) else {
                fileLoadError = "Host not found"
                return
            }
            let data = try await ReadRemoteFile(repository: makeFileRepository(host))(at: file.path)
            guard data.count <= Self.maximumPreviewSize else {
                fileLoadError = "This file is too large to preview on this device."
                return
            }
            guard let content = String(data: data, encoding: .utf8) else {
                fileLoadError = "This file is not UTF-8 text and cannot be previewed."
                return
            }
            codeFile = CodeFile(file: file, content: content)
        } catch {
            fileLoadError = error.localizedDescription
        }
    }

    private static let maximumPreviewSize = 1_000_000
}
