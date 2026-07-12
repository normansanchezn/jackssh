import Foundation
import Domain

public struct HostEditorUIState: Equatable {
    public var name: String
    public var hostname: String
    public var port: String
    public var username: String
    public var showPasswordField: Bool = true
    public var password: String = ""
    public var passwordConfirmation: String = ""
    public var authenticationMethod: SSHAuthMethod = .password
    public var openClawHost: String = ""
    public var openClawPort: String = "18789"
    public var openClawScheme: String = "http"
    public var openClawBasePath: String = "/"
    public var favoriteRemotePath: String = ""
    public var issues: [ValidationIssue] = []
    public var isSaving = false

    public init(host: Domain.Host? = nil) {
        if let host {
            self.name = host.name
            self.hostname = host.hostname
            self.port = String(host.port)
            self.username = host.username
            self.authenticationMethod = host.authenticationMethod
            switch host.authenticationMethod {
            case .password:
                self.showPasswordField = true
            case .publicKey:
                self.showPasswordField = false
            }
            if let openClaw = host.openClawConfiguration {
                self.openClawHost = openClaw.host
                self.openClawPort = String(openClaw.port)
                self.openClawScheme = openClaw.scheme
                self.openClawBasePath = openClaw.basePath
            }
            if let favoriteRemotePath = host.favoriteRemotePath {
                self.favoriteRemotePath = favoriteRemotePath
            }
        } else {
            self.name = ""
            self.hostname = ""
            self.port = "22"
            self.username = ""
            self.authenticationMethod = .password
            self.showPasswordField = true
        }
    }
}
