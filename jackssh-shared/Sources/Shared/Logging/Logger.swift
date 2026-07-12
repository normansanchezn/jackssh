import Foundation
import os.log

public enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARN"
    case error = "ERROR"

    var emoji: String {
        switch self {
        case .debug: return "🔵"
        case .info: return "🟢"
        case .warning: return "🟡"
        case .error: return "🔴"
        }
    }

    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
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
        let timestamp = ISO8601DateFormatter().string(from: Date()).suffix(12)
        let logMessage = "\(level.emoji) [\(level.rawValue)] |\(timestamp)| \(fileName):\(line) → \(function)\n  → \(message)"

        print(logMessage)
        os_log("%{public}s", log: osLog, type: level.osLogType, logMessage)
        #endif
    }

    public static func logNetwork(
        method: String,
        url: String,
        statusCode: Int? = nil,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let level: LogLevel = error != nil ? .error : (statusCode ?? 200) >= 400 ? .warning : .info
        let status = statusCode.map { "[\($0)]" } ?? "[pending]"
        let errorMsg = error.map { " — \($0.localizedDescription)" } ?? ""
        let message = "🌐 \(method) \(url) \(status)\(errorMsg)"

        log(message, level: level, file: file, function: function, line: line)
    }

    public static func logAuth(action: String, email: String, success: Bool) {
        let status = success ? "✅ SUCCESS" : "❌ FAILED"
        let message = "🔐 AUTH [\(action)] \(email) — \(status)"
        log(message, level: success ? .info : .error)
    }

    public static func logSSH(host: String, action: String, status: String) {
        let message = "🔌 SSH [\(host)] \(action) — \(status)"
        log(message, level: status.contains("✅") ? .info : .warning)
    }
}
