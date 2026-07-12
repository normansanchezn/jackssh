import Foundation

/// Lifecycle phase of an interactive terminal connection.
/// Mirrors the states a user needs to see (Termius-style status pill).
public enum TerminalConnectionPhase: Equatable, Sendable {
    case connecting
    case connected
    case reconnecting(attempt: Int)
    case disconnected(reason: String?)
    case failed(String)
}

/// A live PTY channel to a remote host: a raw, bidirectional byte pipe that
/// behaves like a real TTY. The UI feeds `output` into a terminal emulator and
/// forwards keystrokes/control bytes through `send`. There is deliberately no
/// notion of "commands" here — the remote shell owns the prompt, echo, and
/// line editing, exactly like a native terminal.
public protocol TerminalChannel: Sendable {
    /// Raw bytes emitted by the remote PTY (stdout and stderr interleaved, as a
    /// real terminal delivers them). Iterated exactly once by the session.
    var output: AsyncStream<[UInt8]> { get }

    /// Send raw bytes to the remote PTY stdin (keystrokes, `\u{03}` for Ctrl-C,
    /// arrow-key escape sequences, Tab, etc.).
    func send(_ bytes: [UInt8]) async

    /// Inform the remote that the terminal window size changed, so full-screen
    /// programs (vim, htop, progress bars) reflow correctly.
    func resize(cols: Int, rows: Int) async

    /// Tear down the channel and its underlying SSH resources.
    func close() async
}

/// Opens interactive PTY terminal channels to hosts.
/// Implemented in the Data layer over Citadel/NIO-SSH.
public protocol TerminalConnecting: Sendable {
    /// Establish an authenticated SSH connection and request a PTY of the given
    /// initial size. The returned channel is already streaming.
    func connect(to host: Host, cols: Int, rows: Int) async throws -> TerminalChannel
}
