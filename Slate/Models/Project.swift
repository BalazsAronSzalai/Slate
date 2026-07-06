//
//  Project.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: all properties optional or defaulted; no .unique;
// relationships optional with explicit inverses. Zone: ProjectZone (sharable).
@Model
public final class Project {
    public var id: UUID = UUID()
    public var title: String = ""
    public var logline: String = ""
    public var colorHex: String = "#4A90D9"
    public var statusRaw: String = ProjectStatus.active.rawValue
    public var sortOrder: Int = 0
    public var createdAt: Date = Date.now
    public var updatedAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Phase.project)
    public var phases: [Phase]?

    @Relationship(deleteRule: .cascade, inverse: \Draft.project)
    public var drafts: [Draft]?

    @Relationship(deleteRule: .cascade, inverse: \Document.project)
    public var documents: [Document]?

    public var status: ProjectStatus {
        get { ProjectStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    public init(title: String = "", logline: String = "") {
        self.title = title
        self.logline = logline
    }
}