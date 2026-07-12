import Foundation

/// Supplies the aggregated Home snapshot. Implemented in Data.
public protocol HomeStatusRepository: Sendable {
    func currentStatus() async throws -> HomeStatus
}

/// CRUD for managed hosts (non-sensitive fields). Implemented in Data over SwiftData.
public protocol HostRepository: Sendable {
    func all() async throws -> [Host]
    func host(id: UUID) async throws -> Host?
    func save(_ host: Host) async throws
    func delete(id: UUID) async throws
}

/// Abstraction over secure secret storage (Keychain / Secure Enclave). Implemented in Data.
/// Domain never sees the storage mechanism — only get/set/delete of opaque secrets.
public protocol SecretStore: Sendable {
    func secret(for key: String) async throws -> Data?
    func setSecret(_ value: Data, for key: String) async throws
    func removeSecret(for key: String) async throws
}

/// Tracks ephemeral SSH connection state (not persisted). Implemented in Data.
public protocol ConnectionStatusRepository: Sendable {
    func status(for hostID: UUID) async throws -> ConnectionStatus?
    func setStatus(_ status: ConnectionStatus) async throws
    func clearStatus(for hostID: UUID) async throws
}

/// Tracks live SSH sessions owned by this app process. Implemented in Data.
/// Session metadata is deliberately ephemeral: credentials and SSH transports
/// never leave their respective secure/infrastructure layers.
public protocol ConnectionSessionStore: Sendable {
    func activeSession(for hostID: UUID) async -> ConnectedHostSession?
    func mostRecentActiveSession() async -> ConnectedHostSession?
    func activate(_ session: ConnectedHostSession) async
    func deactivate(hostID: UUID) async
}

/// Stores/retrieves SSH credentials (passwords, key material). Implemented in Data.
public protocol CredentialStore: Sendable {
    func storePassword(_ password: String, for hostID: UUID) async throws
    func password(for hostID: UUID) async throws -> String?
    func storePrivateKey(_ keyData: Data, for hostID: UUID) async throws
    func privateKey(for hostID: UUID) async throws -> Data?
    func deleteCredentials(for hostID: UUID) async throws
}

/// SSH connection management. Implemented in Data using Citadel.
public protocol SSHConnectionManager: Sendable {
    func connect(to host: Host, credential: SSHCredential) async throws -> ConnectedHostSession
    func execute(command: String, on session: ConnectedHostSession) async throws -> String
    func openShell(on session: ConnectedHostSession) async throws -> ShellSession
    func disconnect(session: ConnectedHostSession) async throws
}

/// Interactive shell session through SSH.
public protocol ShellSession: Sendable {
    func write(_ input: String) async throws
    func read() async throws -> String?
    func close() async throws
}

/// SFTP file operations. Implemented in Data using Citadel.
public protocol SFTPClient: Sendable {
    func listDirectory(_ path: String) async throws -> [SFTPFileInfo]
    func readFile(_ path: String) async throws -> Data
    func writeFile(_ path: String, data: Data) async throws
    func deleteFile(_ path: String) async throws
    func deleteDirectory(_ path: String) async throws
    func rename(_ from: String, to: String) async throws
}

/// Lists a remote directory for one configured host. Implemented in Data over SFTP.
public protocol RemoteDirectoryRepository: Sendable {
    func listDirectory(at path: String) async throws -> [SFTPFileInfo]
}

/// SFTP file metadata.
public struct SFTPFileInfo: Equatable, Sendable {
    public let name: String
    public let path: String
    public let isDirectory: Bool
    public let size: Int?
    public let modifiedDate: Date?

    public init(
        name: String,
        path: String,
        isDirectory: Bool,
        size: Int? = nil,
        modifiedDate: Date? = nil
    ) {
        self.name = name
        self.path = path
        self.isDirectory = isDirectory
        self.size = size
        self.modifiedDate = modifiedDate
    }
}

/// SSH credential with type and data.
public struct SSHCredential: Equatable, Sendable {
    public enum Kind: Equatable, Sendable {
        case password(String)
        case privateKey(Data, passphrase: String?)
    }

    public let kind: Kind

    public init(_ kind: Kind) {
        self.kind = kind
    }
}

/// Git repository operations. Implemented in Data.
public protocol GitRepositoryClient: Sendable {
    func status(at path: String) async throws -> GitRepositoryStatus
}

/// Dashboard tunnel via SSH local port forwarding. Implemented in Data.
public protocol DashboardTunnelManager: Sendable {
    func createTunnel(
        to configuration: OpenClawConfiguration,
        through session: ConnectedHostSession
    ) async throws -> DashboardTunnel
    func removeTunnel(_ tunnel: DashboardTunnel) async throws
}

/// Local tunnel endpoint for dashboard access.
public struct DashboardTunnel: Equatable, Sendable {
    public let localPort: Int
    public let remoteHost: String
    public let remotePort: Int

    public var url: URL? {
        URL(string: "http://127.0.0.1:\(localPort)/")
    }

    public init(localPort: Int, remoteHost: String, remotePort: Int) {
        self.localPort = localPort
        self.remoteHost = remoteHost
        self.remotePort = remotePort
    }
}

/// Authentication repository (Supabase). Implemented in Data.
public protocol AuthRepository: Sendable {
    func signUp(email: String, password: String) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
    func getCurrentUser() async throws -> User?
    func resetPassword(email: String) async throws
}
