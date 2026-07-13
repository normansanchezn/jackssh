import Foundation
import NetworkExtension
import Shared

@MainActor
final class PacketTunnelConfigurationStore {
    enum PacketTunnelError: Error {
        case managerNotFound
        case connectionUnavailable
    }

    func installOrUpdateConfiguration() async throws {
        let manager = try await loadOrCreateManager()
        let protocolConfiguration = NETunnelProviderProtocol()
        protocolConfiguration.providerBundleIdentifier = NetworkExtensionIdentifiers.packetTunnelProviderBundleIdentifier
        protocolConfiguration.serverAddress = "JackSSH Packet Tunnel"

        manager.localizedDescription = "JackSSH Port Forwarding"
        manager.protocolConfiguration = protocolConfiguration
        manager.isEnabled = true
        try await manager.saveToPreferences()
    }

    func startTunnel() async throws {
        let manager = try await loadEnabledManager()
        try manager.connection.startVPNTunnel()
    }

    func stopTunnel() async throws {
        let manager = try await loadEnabledManager()
        manager.connection.stopVPNTunnel()
    }

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
}
