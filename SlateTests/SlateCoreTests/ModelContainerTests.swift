//
//  ModelContainerTests.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Testing
import SwiftData
@testable import SlateCore

@Suite("Model container smoke tests")
@MainActor
struct ModelContainerTests {

    @Test("In-memory container builds and accepts all V1 models")
    func containerBuilds() throws {
        let container = try SlateModelContainer.make(inMemory: true)
        let context = container.mainContext

        let project = PreviewData.sampleProject()
        context.insert(project)
        context.insert(TimeBlock(milestoneID: UUID()))
        context.insert(AppSettings())
        try context.save()

        let projects = try context.fetch(FetchDescriptor<Project>())
        #expect(projects.count == 1)
        #expect(projects.first?.status == .active)
    }

    @Test("Cascade: deleting a draft removes its feedback notes")
    func draftCascade() throws {
        let container = try SlateModelContainer.make(inMemory: true)
        let context = container.mainContext

        let project = PreviewData.sampleProject()
        context.insert(project)
        let draft = PreviewData.sampleDraft(in: project)
        context.insert(draft)
        PreviewData.sampleFeedbackNotes(on: draft).forEach { context.insert($0) }
        try context.save()

        context.delete(draft)
        try context.save()

        let notes = try context.fetch(FetchDescriptor<FeedbackNote>())
        #expect(notes.isEmpty)
    }

    @Test("PreviewData populates a coherent dataset")
    func previewDataset() throws {
        let container = PreviewData.container()
        let context = container.mainContext

        #expect(try context.fetch(FetchDescriptor<Phase>()).count == 5)
        #expect(try context.fetch(FetchDescriptor<FeedbackNote>()).count == 3)

        // TimeBlock resolves its milestone via loose UUID reference (§4.4.4)
        let block = try #require(try context.fetch(FetchDescriptor<TimeBlock>()).first)
        let milestoneID = try #require(block.milestoneID)
        let milestones = try context.fetch(FetchDescriptor<Milestone>(
            predicate: #Predicate { $0.id == milestoneID }
        ))
        #expect(milestones.count == 1)
    }
}