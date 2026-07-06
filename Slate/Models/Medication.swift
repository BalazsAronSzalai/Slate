//
//  Medication.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: optionals/defaults only. Zone: PRIVATE (C3 — sensitive).
@Model
public final class Medication {
    public var id: UUID = UUID()
    public var name: String = ""
    public var dosage: String = ""
    public var scheduleRule: String = ""       // RRULE string
    public var isActive: Bool = true
    public var notificationIDs: [String] = []

    public init(name: String = "", dosage: String = "") {
        self.name = name
        self.dosage = dosage
    }
}