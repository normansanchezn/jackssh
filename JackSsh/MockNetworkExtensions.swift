import Foundation

// MARK: - Mock Network Extensions for Personal Development Team
// These mocks allow building without Network Extensions capability

#if MOCK_NETWORK_EXTENSIONS

@MainActor
final class MockPacketTunnelConfigurationStore {
    enum PacketTunnelError: Error {
        case managerNotFound
        case connectionUnavailable
        case mockOnlyNoRealFunctionality
    }

    func installOrUpdateConfiguration() async throws {
        print("⚠️ Mock: Would install packet tunnel configuration")
        // In mock mode, we just succeed without doing anything
    }

    func startTunnel() async throws {
        print("⚠️ Mock: Would start packet tunnel")
        throw PacketTunnelError.mockOnlyNoRealFunctionality
    }

    func stopTunnel() async throws {
        print("⚠️ Mock: Would stop packet tunnel")
    }
}

#endif
