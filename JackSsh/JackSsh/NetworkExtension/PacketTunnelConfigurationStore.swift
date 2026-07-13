import Foundation
#if !MOCK_NETWORK_EXTENSIONS
import NetworkExtension
#endif
import Shared

@MainActor
final class PacketTunnelConfigurationStore {
    enum PacketTunnelError: Error {
        case managerNotFound
        case connectionUnavailable
        #if MOCK_NETWORK_EXTENSIONS
        case mockOnlyNoRealFunctionality
        #endif
    }

    func installOrUpdateConfiguration() async throws {
        #if MOCK_NETWORK_EXTENSIONS
        print("⚠️ Mock: Would install packet tunnel configuration (Network Extensions disabled for personal team)")
        // In mock mode, we just succeed without doing anything
        #else
        let manager = try await loadOrCreateManager()
        let protocolConfiguration = NETunnelProviderProtocol()
        protocolConfiguration.providerBundleIdentifier = NetworkExtensionIdentifiers.packetTunnelProviderBundleIdentifier
        protocolConfiguration.serverAddress = "JackSSH Packet Tunnel"

        manager.localizedDescription = "JackSSH Port Forwarding"
        manager.protocolConfiguration = protocolConfiguration
        manager.isEnabled = true
        try await manager.saveToPreferences()
        #endif
    }

    func startTunnel() async throws {
        #if MOCK_NETWORK_EXTENSIONS
        print("⚠️ Mock: Would start packet tunnel (Network Extensions disabled for personal team)")
        throw PacketTunnelError.mockOnlyNoRealFunctionality
        #else
        let manager = try await loadEnabledManager()
        try manager.connection.startVPNTunnel()
        #endif
    }

    func stopTunnel() async throws {
        #if MOCK_NETWORK_EXTENSIONS
        print("⚠️ Mock: Would stop packet tunnel (Network Extensions disabled for personal team)")
        #else
        let manager = try await loadEnabledManager()
        manager.connection.stopVPNTunnel()
        #endif
    }

    #if !MOCK_NETWORK_EXTENSIONS
    private func loadEnabledManager() async throws -> NETunnelProviderManager {
        guard let manager = try await loadManagers().first(where: { manager in
            guard let providerProtocol = manager.protocolConfiguration as? NETunnelProviderProtocol else {
                return false
            }
            return providerProtocol.providerBundleIdentifier == NetworkExtensionIdentifiers.packetTunnelProviderBundleIdentifier
        }) else {
            throw PacketTunnelError.managerNotFound
        }
        return manager
    }

    private func loadOrCreateManager() async throws -> NETunnelProviderManager {
        if let existing = try await loadManagers().first(where: { manager in
            guard let providerProtocol = manager.protocolConfiguration as? NETunnelProviderProtocol else {
                return false
            }
            return providerProtocol.providerBundleIdentifier == NetworkExtensionIdentifiers.packetTunnelProviderBundleIdentifier
        }) {
            return existing
        }

        return NETunnelProviderManager()
    }

    private func loadManagers() async throws -> [NETunnelProviderManager] {
        try await withCheckedThrowingContinuation { continuation in
            NETunnelProviderManager.loadAllFromPreferences { managers, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: managers ?? [])
            }
        }
    }
    #endif
}
