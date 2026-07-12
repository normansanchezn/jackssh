import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class TerminalViewModel {
    public var command: String = ""
    public private(set) var output: [TerminalLine] = []
    public private(set) var isExecuting = false
    public private(set) var error: String?

    private let session: ConnectedHostSession
    private let executeCommand: (String) async throws -> String

    public init(
        session: ConnectedHostSession,
        executeCommand: @escaping (String) async throws -> String = { cmd in
            try await Task.sleep(nanoseconds: 300_000_000)
            return "$ \(cmd)\nCommand executed successfully"
        }
    ) {
        self.session = session
        self.executeCommand = executeCommand
        output.append(TerminalLine(text: "Connected to \(session.username)@\(session.hostname):\(session.port)", isPrompt: true))
        output.append(TerminalLine(text: "", isPrompt: false))
    }

    public func executeCommand() async {
        guard !command.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let cmd = command.trimmingCharacters(in: .whitespaces)
        output.append(TerminalLine(text: "\(cmd)", isPrompt: true))
        command = ""
        isExecuting = true
        error = nil

        do {
            let result = try await self.executeCommand(cmd)
            for line in result.split(separator: "\n", omittingEmptySubsequences: false).map(String.init) {
                output.append(TerminalLine(text: line, isPrompt: false))
            }
            output.append(TerminalLine(text: "", isPrompt: false))
        } catch {
            self.error = error.localizedDescription
            output.append(TerminalLine(text: "Error: \(error.localizedDescription)", isPrompt: false))
        }

        isExecuting = false
    }
}

public struct TerminalLine: Identifiable, Equatable {
    public let id: UUID = UUID()
    public let text: String
    public let isPrompt: Bool

    public static func == (lhs: TerminalLine, rhs: TerminalLine) -> Bool {
        lhs.id == rhs.id && lhs.text == rhs.text && lhs.isPrompt == rhs.isPrompt
    }
}
