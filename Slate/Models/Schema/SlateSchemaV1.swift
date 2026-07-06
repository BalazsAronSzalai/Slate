//
//  SlateSchemaV1.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

/// Frozen at end of Week 1 (§4.5.1). Additive changes only from here (ADR-013).
public enum SlateSchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version { .init(1, 0, 0) }

    /// Shared-eligible models — CloudKit ProjectZone, sharable via CKShare (C1).
    public static var sharedModels: [any PersistentModel.Type] {
        [Project.self, Phase.self, Milestone.self, Draft.self,
         FeedbackNote.self, Document.self]
    }

    /// Private-only models — default private zone, NEVER shared (C2/C3).
    public static var privateModels: [any PersistentModel.Type] {
        [TimeBlock.self, SprintSession.self, Medication.self,
         Appointment.self, Routine.self, IdeaNote.self, AppSettings.self]
    }

    public static var models: [any PersistentModel.Type] {
        sharedModels + privateModels
    }
}

public enum SlateMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] { [SlateSchemaV1.self] }
    public static var stages: [MigrationStage] { [] } // V(N+1) stages appended here
}