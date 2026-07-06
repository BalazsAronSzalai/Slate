//
//  IdeaNote.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: optionals/defaults only. Zone: PRIVATE (C2 — inbox).
@Model
public final class IdeaNote {
    public var id: UUID = UUID()
    public var text: String = ""
    public var capturedViaRaw: String = CaptureChannel.app.rawValue
    public var projectID: UUID?                // loose cross-zone reference
    public var capturedAt: Date = Date.now
    public var processedAt: Date?

    public var capturedVia: CaptureChannel {
        get { CaptureChannel(rawValue: capturedViaRaw) ?? .app }
        set { capturedViaRaw = newValue.rawValue }
    }

    public init(text: String = "", capturedVia: CaptureChannel = .app) {
        self.text = text
        self.capturedViaRaw = capturedVia.rawValue
    }
}