import Foundation
import SwiftData

/// Central definition of the persisted schema and container factory.
/// The app's composition root builds the container from here.
public enum JackSshStore {
    public static let models: [any PersistentModel.Type] = [
        HostRecord.self,
        ServiceDefinitionRecord.self,
        FavoritePathRecord.self,
        EventRecord.self,
        DashboardRecord.self,
    ]

    public static var schema: Schema { Schema(models) }

    /// Builds a `ModelContainer`. `inMemory` is used by tests and previews.
    public static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
