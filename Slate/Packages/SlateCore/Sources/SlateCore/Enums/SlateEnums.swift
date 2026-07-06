//
//  SlateEnums.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation

// CloudKit constraints: enum raw-string values are persisted — NEVER rename, only add. (§6.1.2)

public enum ProjectStatus: String, Codable, Sendable, CaseIterable {
    case active, onHold, archived, delivered
}

public enum PhaseKind: String, Codable, Sendable, CaseIterable {
    case development, preProduction, production, post, delivery, custom
}

public enum MilestoneSource: String, Codable, Sendable, CaseIterable {
    case professor, selfSet = "self"
}

public enum FeedbackSource: String, Codable, Sendable, CaseIterable {
    case professor, peer, selfNote = "self"
}

public enum FeedbackNoteType: String, Codable, Sendable, CaseIterable {
    case general, page, scene
}

public enum FeedbackStatus: String, Codable, Sendable, CaseIterable {
    case open, addressed, resolved
}

public enum DocumentCategory: String, Codable, Sendable, CaseIterable {
    case shotList, storyboard, schedule, budget, callSheet, cut, other
}

public enum DocumentStorageMode: String, Codable, Sendable, CaseIterable {
    case asset, linked
}

public enum DocumentStatus: String, Codable, Sendable, CaseIterable {
    case draft, review, approved, delivered
}

public enum TimeBlockState: String, Codable, Sendable, CaseIterable {
    case proposed, accepted, completed, missed, skipped
}

public enum CaptureChannel: String, Codable, Sendable, CaseIterable {
    case watch, siri, app, share
}
