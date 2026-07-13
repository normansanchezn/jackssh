import Foundation
import NetworkExtension
import os

final class PacketTunnelProvider: NEPacketTunnelProvider {
    private let logger = Logger(subsystem: "dev.normansanchez.JackSsh.PacketTunnel", category: "PacketTunnel")
    private var isTunnelActive = false

    override func startTunnel(
        options: [String: NSObject]?,
        completionHandler: @escaping (Error?) -> Void
    ) {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        settings.mtu = 1_500

        let ipv4Settings = NEIPv4Settings(addresses: ["10.255.0.2"], subnetMasks: ["255.255.255.255"])
        ipv4Settings.includedRoutes = []
        settings.ipv4Settings = ipv4Settings

        setTunnelNetworkSettings(settings) { [weak self] error in
            guard let self else { return }

            if let error {
                self.logger.error("Failed to apply packet tunnel settings: \(error.localizedDescription, privacy: .public)")
                completionHandler(error)
                return
            }

            self.isTunnelActive = true
            self.logger.info("Packet tunnel started")
            completionHandler(nil)
        }
    }

    override func stopTunnel(
        with reason: NEProviderStopReason,
        completionHandler: @escaping () -> Void
    ) {
        isTunnelActive = false
        logger.info("Packet tunnel stopped with reason \(String(describing: reason), privacy: .public)")
        completionHandler()
    }

    override func handleAppMessage(
        _ messageData: Data,
        completionHandler: ((Data?) -> Void)?
    ) {
        completionHandler?(isTunnelActive ? Data("active".utf8) : Data("inactive".utf8))
    }
}
