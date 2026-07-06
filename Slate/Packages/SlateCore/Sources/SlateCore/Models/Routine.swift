//
//  Routine.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: optionals/defaults only. Zone: PRIVATE (C2).
@Model
public final class Routine {
    public var id: UUID = UUID()
    public var title: String = ""
    public var weekdayMask: Int = 0            // bit 0 = Monday … bit 6 = Sunday
    public var startTimeMinutes: Int = 0       // minutes from midnight
    public var durationMinutes: Int = 60
    public var isSchedulerBlocking: Bool = true

    public init(title: String = "") {
        self.title = title
    }
}