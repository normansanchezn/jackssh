#if os(iOS)
import SwiftUI
import SwiftTerm

/// SwiftUI bridge to SwiftTerm's native `TerminalView`. SwiftTerm owns the
/// terminal buffer, ANSI/256-color parsing, scrollback, text selection,
/// copy/paste, and cursor rendering — this wrapper only styles the view, wires
/// its delegate to the `TerminalSession`, and hands the view to the session so
/// remote bytes can be fed in.
struct TerminalEmulatorView: UIViewRepresentable {
    let session: TerminalSession

    func makeUIView(context: Context) -> SwiftTerm.TerminalView {
        let view = SwiftTerm.TerminalView(frame: .zero)

        // Termius-style dark theme.
        view.installColors(TerminalTheme.ansiColors)
        view.nativeBackgroundColor = TerminalTheme.background
        view.nativeForegroundColor = TerminalTheme.foreground
        view.caretColor = TerminalTheme.cursor
        view.selectedTextBackgroundColor = TerminalTheme.selection
        view.backgroundColor = TerminalTheme.background
        view.font = TerminalTheme.font()

        view.terminalDelegate = context.coordinator

        // makeUIView is @MainActor; attach synchronously. The session defaults to
        // an 80x24 PTY until SwiftTerm reports the real size via `sizeChanged`.
        session.attach(view)
        return view
    }

    func updateUIView(_ uiView: SwiftTerm.TerminalView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(session: session)
    }

    final class Coordinator: NSObject, TerminalViewDelegate, @unchecked Sendable {
        // SwiftTerm's delegate callbacks all fire on the UIKit main thread, so
        // `MainActor.assumeIsolated` below is sound at runtime. `nonisolated(unsafe)`
        // stops the compiler treating each capture as a cross-isolation send of
        // the non-Sendable session.
        nonisolated(unsafe) private let session: TerminalSession

        init(session: TerminalSession) {
            self.session = session
        }

        // Keystrokes / control bytes produced by the emulator → remote PTY stdin.
        // This is how Enter, ↑ ↓ history, Ctrl-C (SIGINT), Ctrl-L, and Tab reach
        // the shell: SwiftTerm encodes them into the correct byte sequences.
        func send(source: SwiftTerm.TerminalView, data: ArraySlice<UInt8>) {
            MainActor.assumeIsolated { session.sendToRemote(data) }
        }

        func sizeChanged(source: SwiftTerm.TerminalView, newCols: Int, newRows: Int) {
            MainActor.assumeIsolated { session.resizeRemote(cols: newCols, rows: newRows) }
        }

        func setTerminalTitle(source: SwiftTerm.TerminalView, title: String) {
            MainActor.assumeIsolated { session.setTitle(title) }
        }

        func clipboardCopy(source: SwiftTerm.TerminalView, content: Data) {
            if let string = String(data: content, encoding: .utf8) {
                UIPasteboard.general.string = string
            }
        }

        func clipboardRead(source: SwiftTerm.TerminalView) -> Data? {
            UIPasteboard.general.string?.data(using: .utf8)
        }

        func hostCurrentDirectoryUpdate(source: SwiftTerm.TerminalView, directory: String?) {}
        func scrolled(source: SwiftTerm.TerminalView, position: Double) {}
        func requestOpenLink(source: SwiftTerm.TerminalView, link: String, params: [String: String]) {}
        func bell(source: SwiftTerm.TerminalView) {}
        func iTermContent(source: SwiftTerm.TerminalView, content: ArraySlice<UInt8>) {}
        func rangeChanged(source: SwiftTerm.TerminalView, startY: Int, endY: Int) {}
    }
}

#endif
