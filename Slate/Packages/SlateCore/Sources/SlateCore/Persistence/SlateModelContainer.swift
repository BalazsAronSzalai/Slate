//
//  SlateModelContainer.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

/// Builds the app-wide ModelContainer with TWO store configurations (ADR-008, §4.4.4):
/// physically separate stores so private data can never ride along with a CKShare.
public enum SlateModelContainer {

    public static let appGroupID = "group.BalazsAronSzalai.slate"
    public static let cloudKitContainerID = "iCloud.BalazsAronSzalai.slate"

    public static func make(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: SlateSchemaV1.self)

        if inMemory {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema,
                                      migrationPlan: SlateMigrationPlan.self,
                                      configurations: [config])
        }

        let sharedConfig = ModelConfiguration(
            "SlateShared",
            schema: Schema(SlateSchemaV1.sharedModels),
            groupContainer: .identifier(appGroupID),
            cloudKitDatabase: .private(cloudKitContainerID)
        )
        let privateConfig = ModelConfiguration(
            "SlatePrivate",
            schema: Schema(SlateSchemaV1.privateModels),
            groupContainer: .identifier(appGroupID),
            cloudKitDatabase: .private(cloudKitContainerID)
        )
        return try ModelContainer(for: schema,
                                  migrationPlan: SlateMigrationPlan.self,
                                  configurations: [sharedConfig, privateConfig])
    }

    /// For previews & unit tests (SlateCore/Testing fixtures attach here).
    public static func preview() -> ModelContainer {
        do { return try make(inMemory: true) }
        catch { fatalError("Preview container failed: \(error)") } // previews only — allowed
    }
}