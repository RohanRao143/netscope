// ios/Runner/NetworkMonitor.swift

import Foundation
import Network

final class NetworkMonitor {

    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(
        label: "com.example.netscope.network"
    )

    private(set) var isConnected = false

    private init() {}

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected =
                path.status == .satisfied
        }

        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }
}