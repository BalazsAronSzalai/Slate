//
//  SprintSession.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: optionals/defaults only. Zone: PRIVATE (C2).
@Model
public final class SprintSession {
    public var id: UUID = UUID()
    public var startedAt: Date = Date.now
    public var endedAt: Date?
    public var plannedMinutes: Int = 25
    public var actualMinutes: Int = 0
    public var milestoneID: UUID?              // loose cross-zone reference
    public var wordsOrPagesNote: String?
    public var hourOfDay: Int = 0              // denormalized for stats (§4.4.5)

    public init(startedAt: Date = .now, plannedMinutes: Int = 25) {
        self.startedAt = startedAt
        self.plannedMinutes = plannedMinutes
        self.hourOfDay = Calendar.current.component(.hour, from: startedAt)
    }
}