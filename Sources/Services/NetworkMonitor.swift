import Foundation
import Network

/// Monitors network connectivity using NWPathMonitor.
/// Provides a simple isOnline flag that other services can check before making network calls.
@MainActor
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published var isOnline: Bool = true
    @Published var isExpensive: Bool = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.langly.networkmonitor")

    private init() {}

    /// Starts monitoring network changes. Call once (e.g. from TranslatorManager or app launch).
    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            let online = path.status == .satisfied
            let expensive = path.isExpensive
            Task { @MainActor [weak self] in
                self?.isOnline = online
                self?.isExpensive = expensive
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
