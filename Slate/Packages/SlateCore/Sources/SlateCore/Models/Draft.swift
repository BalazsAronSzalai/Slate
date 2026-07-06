//
//  Draft.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: optionals/defaults only; fileAsset is CKAsset-backed
// via .externalStorage. Zone: ProjectZone.
@Model
public final class Draft {
    public var id: UUID = UUID()
    public var versionNumber: Int = 1
    public var label: String = ""              // e.g. "Treatment v1"
    @Attribute(.externalStorage) public var fileAsset: Data?
    public var fileName: String = ""
    public var fileUTI: String = ""
    public var importedAt: Date = Date.now
    public var notesSummaryCache: String = ""  // denormalized for widgets (§4.4.5)

    public var project: Project?

    @Relationship(deleteRule: .cascade, inverse: \FeedbackNote.draft)
    public var feedbackNotes: [FeedbackNote]?

    public var supersedes: Draft?              // previous version link (compare view)

    public init(versionNumber: Int = 1, label: String = "") {
        self.versionNumber = versionNumber
        self.label = label
    }
}