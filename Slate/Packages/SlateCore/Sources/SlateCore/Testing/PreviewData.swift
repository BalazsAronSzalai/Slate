//
//  PreviewData.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

/// Mock fixtures for #Previews and unit tests (§6.1.4).
/// All data is inserted into an in-memory container — never touches CloudKit.
public enum PreviewData {

    // MARK: - Container

    /// In-memory container pre-populated with a realistic student-film dataset.
    @MainActor
    public static func container() -> ModelContainer {
        let container = SlateModelContainer.preview()
        populate(context: container.mainContext)
        return container
    }

    // MARK: - Individual fixtures

    public static func sampleProject() -> Project {
        let project = Project(title: "Thesis Short — \"Fénykép\"",
                              logline: "A photographer discovers her archive is remembering things she never shot.")
        project.colorHex = "#4A90D9"
        return project
    }

    public static func samplePhases(for project: Project) -> [Phase] {
        let kinds: [(String, PhaseKind)] = [
            ("Development", .development),
            ("Pre-Production", .preProduction),
            ("Production", .production),
            ("Post", .post),
            ("Delivery", .delivery)
        ]
        return kinds.enumerated().map { index, pair in
            let phase = Phase(name: pair.0, kind: pair.1, sortOrder: index)
            phase.project = project
            return phase
        }
    }

    public static func sampleMilestone(in phase: Phase,
                                       title: String = "Treatment due",
                                       daysFromNow: Int = 7) -> Milestone {
        let milestone = Milestone(
            title: title,
            deadline: Calendar.current.date(byAdding: .day, value: daysFromNow, to: .now),
            estimatedHours: 6.0
        )
        milestone.source = .professor
        milestone.phase = phase
        return milestone
    }

    public static func sampleDraft(in project: Project) -> Draft {
        let draft = Draft(versionNumber: 1, label: "Treatment v1")
        draft.fileName = "fenykep-treatment-v1.pdf"
        draft.fileUTI = "com.adobe.pdf"
        draft.notesSummaryCache = "3 notes, 2 unresolved"
        draft.project = project
        return draft
    }

    public static func sampleFeedbackNotes(on draft: Draft) -> [FeedbackNote] {
        let professorNote = FeedbackNote(text: "Act two sags — cut the darkroom montage.", source: .professor)
        professorNote.noteType = .page
        professorNote.pageNumber = 4
        professorNote.draft = draft

        let peerNote = FeedbackNote(text: "Love the ending image. Keep it.", source: .peer)
        peerNote.status = .resolved
        peerNote.draft = draft

        let privateNote = FeedbackNote(text: "I disagree but will try his version first.", source: .selfNote)
        privateNote.isPrivate = true
        privateNote.draft = draft

        return [professorNote, peerNote, privateNote]
    }

    public static func sampleTimeBlock(milestoneID: UUID?) -> TimeBlock {
        let start = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: .now) ?? .now
        let block = TimeBlock(start: start,
                              end: start.addingTimeInterval(90 * 60),
                              milestoneID: milestoneID)
        block.plannedMinutes = 90
        block.state = .accepted
        return block
    }

    // MARK: - Bulk population

    @MainActor
    private static func populate(context: ModelContext) {
        let project = sampleProject()
        context.insert(project)

        let phases = samplePhases(for: project)
        phases.forEach { context.insert($0) }

        let milestone = sampleMilestone(in: phases[0])
        context.insert(milestone)

        let draft = sampleDraft(in: project)
        context.insert(draft)
        sampleFeedbackNotes(on: draft).forEach { context.insert($0) }

        context.insert(sampleTimeBlock(milestoneID: milestone.id))
        context.insert(AppSettings())

        do { try context.save() } catch {
            assertionFailure("PreviewData populate failed: \(error)") // previews/tests only
        }
    }
}