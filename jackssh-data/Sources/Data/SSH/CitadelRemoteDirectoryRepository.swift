import Citadel
import Foundation
import Domain

/// SFTP-backed remote directory browser. Each listing uses an isolated SSH/SFTP
/// channel, keeping it independent from the interactive terminal's PTY.
public struct CitadelRemoteDirectoryRepository: RemoteDirectoryRepository, RemoteFileRepository {
    private let host: Domain.Host
    private let secretStore: SecretStore

    public init(host: Domain.Host, secretStore: SecretStore) {
        self.host = host
        self.secretStore = secretStore
    }

    public func listDirectory(at path: String) async throws -> [SFTPFileInfo] {
        let client = try await connect()

        do {
            let files = try await client.withSFTP { sftp in
                let entries = try await sftp.listDirectory(atPath: path)
                var files: [SFTPFileInfo] = []
                for response in entries {
                    for entry in response.components where entry.filename != "." && entry.filename != ".." {
                        let file = SFTPFileInfo(
                            name: entry.filename,
                            path: Self.join(path, entry.filename),
                            isDirectory: entry.longname.hasPrefix("d"),
                            size: entry.attributes.size.map(Int.init),
                            modifiedDate: entry.attributes.accessModificationTime?.modificationTime
                        )
                        files.append(file)
                    }
                }
                return files.sorted(by: Self.sort)
            }
            try await client.close()
            return files
        } catch {
            try? await client.close()
            throw error
        }
    }

    public func readFile(at path: String) async throws -> Data {
        let client = try await connect()

        do {
            let data = try await client.withSFTP { sftp in
                let buffer = try await sftp.withFile(filePath: path, flags: .read) { file in
                    try await file.readAll()
                }
                return Data(buffer.readableBytesView)
            }
            try await client.close()
            return data
        } catch {
            try? await client.close()
            throw error
        }
    }

    private func connect() async throws -> SSHClient {
        guard host.authenticationMethod == .password else {
            throw DomainError.unknown
        }
        let key = SecretKey.password(hostID: host.id)
        guard let data = try await secretStore.secret(for: key),
              let password = String(data: data, encoding: .utf8) else {
            throw DomainError.notFound
        }
        return try await SSHClient.connect(
            host: host.hostname,
            port: host.port,
            authenticationMethod: .passwordBased(username: host.username, password: password),
            hostKeyValidator: .acceptAnything(),
            reconnect: .never,
            connectTimeout: .seconds(15)
        )
    }

    private static func join(_ directory: String, _ name: String) -> String {
        directory == "/" ? "/\(name)" : directory + "/" + name
    }

    private static func sort(_ lhs: SFTPFileInfo, _ rhs: SFTPFileInfo) -> Bool {
        if lhs.isDirectory != rhs.isDirectory { return lhs.isDirectory }
        return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}
