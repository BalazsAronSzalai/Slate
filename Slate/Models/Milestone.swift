//
//  Milestone.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: optionals/defaults only. Zone: ProjectZone.
// #Index on deadline (§4.4.5).
@Model
public final class Milestone {
    public var id: UUID = UUID()
    public var title: String = ""
    public var deadline: Date?                 // nil = undated
    public var estimatedHours: Double = 4.0    // engine input
    public var remainingHours: Double = 4.0    // engine-maintained
    public var weight: Double = 1.0            // phase weight for urgency scoring
    public var isCompleted: Bool = false
    public var completedAt: Date?
    public var sourceRaw: String = MilestoneSource.selfSet.rawValue
    public var reminderID: String?             // EventKit back-link

    public var phase: Phase?

    public var source: MilestoneSource {
        get { MilestoneSource(rawValue: sourceRaw) ?? .selfSet }
        set { sourceRaw = newValue.rawValue }
    }

    public init(title: String = "", deadline: Date? = nil, estimatedHours: Double = 4.0) {
        self.title = title
        self.deadline = deadline
        self.estimatedHours = estimatedHours
        self.remainingHours = estimatedHours
    }
}