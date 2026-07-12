import Foundation

public struct EnvironmentConfig {
    public static let supabaseURL: URL = {
        // Priority: env var → local detection → prod fallback
        if let envURL = ProcessInfo.processInfo.environment["SUPABASE_URL"],
           let url = URL(string: envURL) {
            return url
        }

        // Local development detection
        #if DEBUG
        if let localIP = getLocalIPAddress() {
            return URL(string: "http://\(localIP):54321") ?? productionURL
        }
        #endif

        return productionURL
    }()

    public static let supabaseKey: String = {
        // Priority: env var → local key → prod key
        if let envKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] {
            return envKey
        }

        #if DEBUG
        return localDevKey
        #else
        return productionKey
        #endif
    }()

    private static let productionURL = URL(string: "https://qaqotvrvqglmgjlyesnf.supabase.co")!
    private static let productionKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFhcW90dnJ2cWdsbWdqbHllc25mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4MTAzMTAsImV4cCI6MjA5OTM4NjMxMH0.M4mYOLnF4vo2dgV-NFGywHb7hRHXeygtl_vAyKYtOXI"

    private static let localDevKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"

    private static func getLocalIPAddress() -> String? {
        var addressList: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addressList) == 0, let firstAddr = addressList else { return nil }

        defer { freeifaddrs(firstAddr) }

        var currentAddr = firstAddr
        while currentAddr.pointee.ifa_next != nil {
            let addr = currentAddr.pointee
            let family = addr.ifa_addr.pointee.sa_family

            // IPv4 only
            if family == AF_INET {
                var hostname = [Int8](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(
                    addr.ifa_addr,
                    socklen_t(addr.ifa_addr.pointee.sa_len),
                    &hostname,
                    socklen_t(hostname.count),
                    nil,
                    0,
                    NI_NUMERICHOST
                ) == 0 {
                    let address = String(cString: hostname)

                    // Skip loopback & link-local
                    if !address.hasPrefix("127.") && !address.hasPrefix("169.") {
                        return address
                    }
                }
            }

            currentAddr = currentAddr.pointee.ifa_next
        }

        return nil
    }
}
