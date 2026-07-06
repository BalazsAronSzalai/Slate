//
//  Phase.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: optionals/defaults only; inverse declared on child side. Zone: ProjectZone.
@Model
public final class Phase {
    public var id: UUID = UUID()
    public var name: String = ""
    public var kindRaw: String = PhaseKind.custom.rawValue
    public var sortOrder: Int = 0

    public var project: Project?

    @Relationship(deleteRule: .cascade, inverse: \Milestone.phase)
    public var milestones: [Milestone]?

    public var kind: PhaseKind {
        get { PhaseKind(rawValue: kindRaw) ?? .custom }
        set { kindRaw = newValue.rawValue }
    }

    public init(name: String = "", kind: PhaseKind = .custom, sortOrder: Int = 0) {
        self.name = name
        self.kindRaw = kind.rawValue
        self.sortOrder = sortOrder
    }
}