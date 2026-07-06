//
//  TimeBlock.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: optionals/defaults only. Zone: PRIVATE (never shared, C2).
// milestoneID is a loose UUID reference across stores (§4.4.4). #Index on start.
@Model
public final class TimeBlock {
    public var id: UUID = UUID()
    public var start: Date = Date.now
    public var end: Date = Date.now
    public var stateRaw: String = TimeBlockState.proposed.rawValue
    public var calendarEventID: String?
    public var milestoneID: UUID?              // loose cross-zone reference
    public var plannedMinutes: Int = 45        // ADR-014: min block 45 min
    public var actualMinutes: Int = 0

    public var state: TimeBlockState {
        get { TimeBlockState(rawValue: stateRaw) ?? .proposed }
        set { stateRaw = newValue.rawValue }
    }

    public init(start: Date = .now, end: Date = .now, milestoneID: UUID? = nil) {
        self.start = start
        self.end = end
        self.milestoneID = milestoneID
    }
}