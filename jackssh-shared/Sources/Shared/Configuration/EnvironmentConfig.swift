import Foundation

public struct EnvironmentConfig {
    public static let supabaseURL: URL = {
        // The app uses the hosted Supabase project by default. Local Supabase
        // is opt-in only through an explicitly injected environment variable.
        if let envURL = ProcessInfo.processInfo.environment["SUPABASE_URL"],
           let url = URL(string: envURL) {
            return url
        }

        return productionURL
    }()

    public static let supabaseKey: String = {
        // Accept both the app's historic name and the conventional anon-key
        // name used in the local environment file and deployment systems.
        if let envKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"]
            ?? ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] {
            return envKey
        }

        return productionKey
    }()

    private static let productionURL = URL(string: "https://qaqotvrvqglmgjlyesnf.supabase.co")!
    private static let productionKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFhcW90dnJ2cWdsbWdqbHllc25mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4MTAzMTAsImV4cCI6MjA5OTM4NjMxMH0.M4mYOLnF4vo2dgV-NFGywHb7hRHXeygtl_vAyKYtOXI"
}
