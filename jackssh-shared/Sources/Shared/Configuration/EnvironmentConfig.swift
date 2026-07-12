import Foundation

public struct EnvironmentConfig {
    public static let supabaseURL: URL = {
        // Priority: env var → local dev → prod fallback
        if let envURL = ProcessInfo.processInfo.environment["SUPABASE_URL"],
           let url = URL(string: envURL) {
            return url
        }

        // Local development — use 127.0.0.1 directly (simulador friendly)
        #if DEBUG
        return URL(string: "http://127.0.0.1:54321") ?? productionURL
        #else
        return productionURL
        #endif
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
}
