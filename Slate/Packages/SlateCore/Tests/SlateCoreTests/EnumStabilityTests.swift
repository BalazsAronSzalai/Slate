//
//  EnumStabilityTests.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Testing
@testable import SlateCore

/// Enum raw-string values are CloudKit-persisted API — NEVER rename, only add (§6.1.2).
/// These tests freeze V1 raw values. If one fails, you renamed a persisted value:
/// revert, and add a new case instead.
@Suite("Enum raw-value stability (SchemaV1 freeze)")
struct EnumStabilityTests {

    @Test func projectStatus() {
        #expect(ProjectStatus.active.rawValue == "active")
        #expect(ProjectStatus.onHold.rawValue == "onHold")
        #expect(ProjectStatus.archived.rawValue == "archived")
        #expect(ProjectStatus.delivered.rawValue == "delivered")
    }

    @Test func phaseKind() {
        #expect(PhaseKind.development.rawValue == "development")
        #expect(PhaseKind.preProduction.rawValue == "preProduction")
        #expect(PhaseKind.production.rawValue == "production")
        #expect(PhaseKind.post.rawValue == "post")
        #expect(PhaseKind.delivery.rawValue == "delivery")
        #expect(PhaseKind.custom.rawValue == "custom")
    }

    @Test func sources() {
        #expect(MilestoneSource.professor.rawValue == "professor")
        #expect(MilestoneSource.selfSet.rawValue == "self")
        #expect(FeedbackSource.professor.rawValue == "professor")
        #expect(FeedbackSource.peer.rawValue == "peer")
        #expect(FeedbackSource.selfNote.rawValue == "self")
    }

    @Test func feedbackAndDocument() {
        #expect(FeedbackStatus.open.rawValue == "open")
        #expect(FeedbackStatus.addressed.rawValue == "addressed")
        #expect(FeedbackStatus.resolved.rawValue == "resolved")
        #expect(DocumentStorageMode.asset.rawValue == "asset")
        #expect(DocumentStorageMode.linked.rawValue == "linked")
        #expect(DocumentStatus.draft.rawValue == "draft")
        #expect(DocumentStatus.approved.rawValue == "approved")
    }

    @Test func timeBlockAndCapture() {
        #expect(TimeBlockState.proposed.rawValue == "proposed")
        #expect(TimeBlockState.accepted.rawValue == "accepted")
        #expect(TimeBlockState.completed.rawValue == "completed")
        #expect(TimeBlockState.missed.rawValue == "missed")
        #expect(TimeBlockState.skipped.rawValue == "skipped")
        #expect(CaptureChannel.watch.rawValue == "watch")
        #expect(CaptureChannel.siri.rawValue == "siri")
        #expect(CaptureChannel.app.rawValue == "app")
        #expect(CaptureChannel.share.rawValue == "share")
    }
}