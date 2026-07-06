//
//  ZoneSeparationTests.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Testing
import SwiftData
@testable import SlateCore

/// §4.7.4 invariant 3: C2/C3 models must physically reside in the non-shared
/// store configuration. If this test fails, private data could ride along
/// with a CKShare — treat any failure as SEVERITY: CRITICAL.
@Suite("Zone separation (ADR-008, §4.4.4)")
struct ZoneSeparationTests {

    @Test("Private models are never listed in the shared schema")
    func privateModelsExcludedFromSharedSchema() {
        let sharedNames = Set(SlateSchemaV1.sharedModels.map { String(describing: $0) })
        let privateNames = Set(SlateSchemaV1.privateModels.map { String(describing: $0) })

        #expect(sharedNames.isDisjoint(with: privateNames))

        // Explicit denylist — every C2/C3 model must be private-only.
        for name in ["TimeBlock", "SprintSession", "Medication",
                     "Appointment", "Routine", "IdeaNote", "AppSettings"] {
            #expect(privateNames.contains(name), "\(name) must be in privateModels")
            #expect(!sharedNames.contains(name), "\(name) must NOT be shared-eligible")
        }
    }

    @Test("Shared schema contains exactly the C1 whitelist")
    func sharedSchemaWhitelist() {
        let sharedNames = Set(SlateSchemaV1.sharedModels.map { String(describing: $0) })
        let expected: Set = ["Project", "Phase", "Milestone", "Draft", "FeedbackNote", "Document"]
        #expect(sharedNames == expected)
    }

    @Test("No relationship crosses the store boundary")
    func noCrossStoreRelationships() {
        // Private models reference shared entities by UUID only (§4.4.4).
        // Verify via SwiftData metadata: no relationship on a private model
        // targets a shared model type.
        let sharedNames = Set(SlateSchemaV1.sharedModels.map { String(describing: $0) })
        let schema = Schema(SlateSchemaV1.privateModels)

        for entity in schema.entities {
            for relationship in entity.relationships {
                let destination = relationship.destination
                #expect(!sharedNames.contains(destination),
                        "\(entity.name).\(relationship.name) illegally targets shared model \(destination)")
            }
        }
    }
}