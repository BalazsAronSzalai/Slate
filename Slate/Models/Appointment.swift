//
//  Appointment.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: optionals/defaults only. Zone: PRIVATE (C2).
@Model
public final class Appointment {
    public var id: UUID = UUID()
    public var title: String = ""
    public var date: Date = Date.now
    public var location: String?
    public var calendarEventID: String?

    public init(title: String = "", date: Date = .now) {
        self.title = title
        self.date = date
    }
}