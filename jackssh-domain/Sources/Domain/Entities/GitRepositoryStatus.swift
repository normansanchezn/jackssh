import Foundation

/// Status of a single file in Git working tree.
public struct GitStatusEntry: Equatable, Hashable, Sendable {
    public enum Change: String, Equatable, Hashable, Sendable {
        case modified = "M"
        case added = "A"
        case deleted = "D"
        case renamed = "R"
        case copied = "C"
        case typeChanged = "T"
        case unmerged = "U"
        case untracked = "?"

        public var displayName: String {
            switch self {
            case .modified: return "Modified"
            case .added: return "Added"
            case .deleted: return "Deleted"
            case .renamed: return "Renamed"
            case .copied: return "Copied"
            case .typeChanged: return "Type changed"
            case .unmerged: return "Unmerged"
            case .untracked: return "Untracked"
            }
        }
    }

    public let path: String
    public let change: Change
    public let staged: Bool

    public init(path: String, change: Change, staged: Bool = false) {
        self.path = path
        self.change = change
        self.staged = staged
    }
}

/// Summary of Git commit.
public struct GitCommitSummary: Equatable, Sendable {
    public let hash: String
    public let subject: String

    public init(hash: String, subject: String) {
        self.hash = hash
        self.subject = subject
    }
}

/// Status of a Git repository.
public struct GitRepositoryStatus: Equatable, Sendable {
    public enum Status: Equatable, Sendable {
        case clean
        case modified([GitStatusEntry])
        case staged([GitStatusEntry])
        case conflicted([GitStatusEntry])
        case notRepository(String)
        case unavailable(String)
    }

    public let repositoryRoot: String
    public let branch: String?
    public let lastCommit: GitCommitSummary?
    public let status: Status
    public let checkedAt: Date

    public init(
        repositoryRoot: String,
        branch: String? = nil,
        lastCommit: GitCommitSummary? = nil,
        status: Status = .clean,
        checkedAt: Date = Date()
    ) {
        self.repositoryRoot = repositoryRoot
        self.branch = branch
        self.lastCommit = lastCommit
        self.status = status
        self.checkedAt = checkedAt
    }

    public var isClean: Bool {
        if case .clean = status {
            return true
        }
        return false
    }

    public var entries: [GitStatusEntry] {
        switch status {
        case .clean: return []
        case let .modified(entries): return entries
        case let .staged(entries): return entries
        case let .conflicted(entries): return entries
        case .notRepository, .unavailable: return []
        }
    }
}
