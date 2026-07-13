import Domain

public struct RemoteFilesUIState: Equatable {
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

    public var path: String
    public var state: ViewState = .idle
    public var codeFile: CodeFile?
    public var fileLoadError: String?
    public var isLoadingFile = false
    public var favoriteRoutes: [String] = []

    public init(path: String = "/") {
        self.path = path
    }
}
