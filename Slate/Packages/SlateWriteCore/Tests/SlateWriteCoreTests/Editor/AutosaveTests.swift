import XCTest
@testable import SlateWriteCore

final class AutosaveTests: XCTestCase {
    
    // MARK: - Version Snapshot Creation
    
    func testCreatesVersionSnapshot() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. FIRST"))
        let editor = ScreenplayEditor(document: document)
        
        await editor.createSnapshot(name: "Initial Draft")
        
        let snapshots = await editor.snapshots()
        XCTAssertEqual(snapshots.count, 1)
        XCTAssertEqual(snapshots[0].name, "Initial Draft")
    }
    
    func testSnapshotCapturesDocumentState() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. FIRST"))
        document.appendBlock(ScreenplayBlock(element: .action, text: "Action"))
        let editor = ScreenplayEditor(document: document)
        
        await editor.createSnapshot(name: "Snapshot 1")
        
        // Modify document
        await editor.insertBlock(text: "INT. SECOND", at: 2)
        
        // Restore snapshot
        await editor.restoreSnapshot(at: 0)
        
        let blockCount = await editor.blockCount()
        XCTAssertEqual(blockCount, 2) // Should have 2 blocks from snapshot
    }
    
    func testSnapshotIncludesTimestamp() async {
        var document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        let before = Date()
        try? await Task.sleep(nanoseconds: 10_000_000)
        await editor.createSnapshot(name: "Test")
        try? await Task.sleep(nanoseconds: 10_000_000)
        let after = Date()
        
        let snapshots = await editor.snapshots()
        XCTAssertGreaterThanOrEqual(snapshots[0].createdAt, before)
        XCTAssertLessThanOrEqual(snapshots[0].createdAt, after)
    }
    
    func testCreatesMultipleSnapshots() async {
        var document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.createSnapshot(name: "Snapshot 1")
        try? await Task.sleep(nanoseconds: 10_000_000)
        await editor.createSnapshot(name: "Snapshot 2")
        
        let snapshots = await editor.snapshots()
        XCTAssertEqual(snapshots.count, 2)
        XCTAssertEqual(snapshots[0].name, "Snapshot 1")
        XCTAssertEqual(snapshots[1].name, "Snapshot 2")
    }
    
    // MARK: - Snapshot Restoration
    
    func testRestoresSnapshot() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. FIRST"))
        let editor = ScreenplayEditor(document: document)
        
        await editor.createSnapshot(name: "Original")
        
        // Modify document
        await editor.updateBlock(at: 0, text: "INT. MODIFIED")
        
        // Restore snapshot
        await editor.restoreSnapshot(at: 0)
        
        let text = await editor.text(at: 0)
        XCTAssertEqual(text, "INT. FIRST")
    }
    
    func testRestoringSnapshotUpdatesDocumentTimestamp() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. FIRST"))
        let editor = ScreenplayEditor(document: document)
        
        await editor.createSnapshot(name: "Original")
        
        let originalUpdatedAt = await editor.documentUpdatedAt()
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        await editor.restoreSnapshot(at: 0)
        
        let updatedAt = await editor.documentUpdatedAt()
        XCTAssertGreaterThan(updatedAt, originalUpdatedAt)
    }
    
    // MARK: - Snapshot Deletion
    
    func testDeletesSnapshot() async {
        var document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.createSnapshot(name: "Snapshot 1")
        await editor.createSnapshot(name: "Snapshot 2")
        
        await editor.deleteSnapshot(at: 0)
        
        let snapshots = await editor.snapshots()
        XCTAssertEqual(snapshots.count, 1)
        XCTAssertEqual(snapshots[0].name, "Snapshot 2")
    }
    
    func testDeletingNonExistentSnapshotDoesNothing() async {
        var document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.createSnapshot(name: "Snapshot 1")
        
        // Try to delete snapshot at invalid index
        await editor.deleteSnapshot(at: 5)
        
        let snapshots = await editor.snapshots()
        XCTAssertEqual(snapshots.count, 1)
    }
    
    // MARK: - Snapshot Limits
    
    func testEnforcesMaximumSnapshotCount() async {
        var document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        // Create more snapshots than the limit (assuming limit of 10)
        for i in 0..<15 {
            await editor.createSnapshot(name: "Snapshot \(i)")
        }
        
        let snapshots = await editor.snapshots()
        // Should keep only the most recent snapshots
        XCTAssertLessThanOrEqual(snapshots.count, 10)
    }
    
    // MARK: - Autosave Behavior
    
    func testAutosaveOnDocumentChange() async {
        var document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.insertBlock(text: "INT. FIRST", at: 0)
        
        // After modification, there should be an autosave snapshot
        let snapshots = await editor.snapshots()
        let autosaveSnapshots = snapshots.filter { $0.name.hasPrefix("Autosave") }
        XCTAssertGreaterThan(autosaveSnapshots.count, 0)
    }
    
    func testAutosaveDoesNotCreateDuplicateSnapshots() async {
        var document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.insertBlock(text: "INT. FIRST", at: 0)
        let firstCount = (await editor.snapshots()).filter { $0.name.hasPrefix("Autosave") }.count
        
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        await editor.insertBlock(text: "INT. SECOND", at: 1)
        let secondCount = (await editor.snapshots()).filter { $0.name.hasPrefix("Autosave") }.count
        
        // Should create new autosave snapshot, not duplicate
        XCTAssertGreaterThan(secondCount, firstCount)
    }
}
