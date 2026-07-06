//
//  AppSettings.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: optionals/defaults only; single-row by convention
// (no .unique allowed — fetch-first-or-create in SettingsService). Zone: PRIVATE (C2).
@Model
public final class AppSettings {
    public var id: UUID = UUID()
    public var briefingTimeMinutes: Int = 450          // 07:30
    public var workHoursStartMinutes: Int = 540        // 09:00
    public var workHoursEndMinutes: Int = 1260         // 21:00
    public var minBlockMinutes: Int = 45               // ADR-014
    public var maxDailyDeepWorkHours: Double = 6.0
    public var lowSleepThresholdHours: Double = 6.0
    public var preferredLocaleID: String = ""          // "" = system
    public var notificationsEnabled: Bool = true
    public var briefingEnabled: Bool = true
    public var deadlineLadderEnabled: Bool = true

    public init() {}
}