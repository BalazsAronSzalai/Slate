//
//  FeedbackNote.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: optionals/defaults only. Zone: ProjectZone.
// NOTE (§4.4.2): notes with isPrivate == true must be excluded from shares —
// ShareService enforces; the isPrivate flag additionally gates shared-view rendering.
// #Index on statusRaw (§4.4.5).
@Model
public final class FeedbackNote {
    public var id: UUID = UUID()
    public var text: String = ""
    public var sourceRaw: String = FeedbackSource.selfNote.rawValue
    public var noteTypeRaw: String = FeedbackNoteType.general.rawValue
    public var pageNumber: Int?
    public var sceneRef: String?
    public var statusRaw: String = FeedbackStatus.open.rawValue
    public var isPrivate: Bool = false
    @Attribute(.externalStorage) public var audioAsset: Data?   // voice memo (m4a)
    public var transcript: String?
    public var resolvedInDraftID: UUID?
    public var reminderID: String?
    public var createdAt: Date = Date.now

    public var draft: Draft?

    public var source: FeedbackSource {
        get { FeedbackSource(rawValue: sourceRaw) ?? .selfNote }
        set { sourceRaw = newValue.rawValue }
    }
    public var noteType: FeedbackNoteType {
        get { FeedbackNoteType(rawValue: noteTypeRaw) ?? .general }
        set { noteTypeRaw = newValue.rawValue }
    }
    public var status: FeedbackStatus {
        get { FeedbackStatus(rawValue: statusRaw) ?? .open }
        set { statusRaw = newValue.rawValue }
    }

    public init(text: String = "", source: FeedbackSource = .selfNote) {
        self.text = text
        self.sourceRaw = source.rawValue
    }
}