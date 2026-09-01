// ios/PacketFilterExtension/PacketTunnelProvider.swift

import NetworkExtension

final class PacketTunnelProvider:
    NEPacketTunnelProvider {

    override func startTunnel(
        options:
            [String : NSObject]?,
        completionHandler:
            @escaping (Error?) -> Void
    ) {

        /*
         * NetworkExtension packet tunnels require the appropriate
         * Apple-managed entitlement and provisioning configuration.
         *
         * This extension deliberately does not install a default route
         * until a complete packet forwarding implementation is present.
         *
         * Installing a catch-all route without forwarding packets would
         * interrupt the user's network connection.
         */

        let settings = NEPacketTunnelNetworkSettings(
            tunnelRemoteAddress: "192.0.2.1"
        )

        settings.ipv4Settings =
            NEIPv4Settings(
                addresses: ["192.0.2.2"],
                subnetMasks: ["255.255.255.0"]
            )

        settings.ipv4Settings?.includedRoutes = []

        setTunnelNetworkSettings(
            settings
        ) { error in
            completionHandler(error)
        }
    }

    override func stopTunnel(
        with reason:
            NEProviderStopReason,
        completionHandler:
            @escaping () -> Void
    ) {

        completionHandler()
    }

    override func handleAppMessage(
        _ messageData: Data,
        completionHandler:
            ((Data?) -> Void)? = nil
    ) {

        completionHandler?(nil)
    }

    override func sleep(
        with completionHandler:
            @escaping () -> Void
    ) {

        completionHandler()
    }

    override func wake() {}
}