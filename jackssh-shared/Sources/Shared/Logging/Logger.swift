import Foundation
import os.log

public enum LogLevel: String {
    case debug = "🔵 DEBUG"
    case info = "🟢 INFO"
    case warning = "🟡 WARNING"
    case error = "🔴 ERROR"
}

public struct AppLogger {
    private static let osLog = OSLog(subsystem: "dev.normansanchez.JackSsh", category: "app")

    public static func log(
        _ message: String,
        level: LogLevel = .info,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logMessage = "[\(timestamp)] [\(fileName):\(line)] \(function) - \(level.rawValue): \(message)"

        os_log("%{public}s", log: osLog, type: .debug, logMessage)
        print(logMessage)
        #endif
    }

    public static func logCredential(hostID: String, found: Bool) {
        let status = found ? "✅ FOUND" : "❌ NOT FOUND"
        log("Credential for host \(hostID): \(status)", level: .debug)
    }

    public static func logCredentialStore(hostID: String, action: String) {
        log("Credential Store [\(action)]: host=\(hostID)", level: .debug)
    }

    public static func logConnection(host: String, step: String) {
        log("Connection [\(host)]: \(step)", level: .debug)
    }
}
