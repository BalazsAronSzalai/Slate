import XCTest
@testable import SlateWriteCore

final class EditorTextInputTests: XCTestCase {
    
    // MARK: - Insert Block with Auto-Detection
    
    func testInsertBlockWithSceneHeadingTextAutoDetects() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.insertBlock(text: "INT. COFFEE SHOP - DAY", at: 0)
        
        let count = await editor.blockCount()
        let element = await editor.element(at: 0)
        let text = await editor.text(at: 0)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(element, .sceneHeading)
        XCTAssertEqual(text, "INT. COFFEE SHOP - DAY")
    }
    
    func testInsertBlockWithTransitionTextAutoDetects() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.insertBlock(text: "CUT TO:", at: 0)
        
        let count = await editor.blockCount()
        let element = await editor.element(at: 0)
        let text = await editor.text(at: 0)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(element, .transition)
        XCTAssertEqual(text, "CUT TO:")
    }
    
    func testInsertBlockWithCharacterTextAutoDetects() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.insertBlock(text: "JOHN", at: 0)
        
        let count = await editor.blockCount()
        let element = await editor.element(at: 0)
        let text = await editor.text(at: 0)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(element, .character)
        XCTAssertEqual(text, "JOHN")
    }
    
    func testInsertBlockWithParentheticalTextAutoDetects() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.insertBlock(text: "(whispering)", at: 0)
        
        let count = await editor.blockCount()
        let element = await editor.element(at: 0)
        let text = await editor.text(at: 0)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(element, .parenthetical)
        XCTAssertEqual(text, "(whispering)")
    }
    
    func testInsertBlockWithActionTextAutoDetects() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.insertBlock(text: "John walks into the room.", at: 0)
        
        let count = await editor.blockCount()
        let element = await editor.element(at: 0)
        let text = await editor.text(at: 0)
        
        XCTAssertEqual(count, 1)
        XCTAssertEqual(element, .action)
        XCTAssertEqual(text, "John walks into the room.")
    }
    
    // MARK: - Update Block Text with Auto-Detection
    
    func testUpdateBlockTextAutoDetectsElement() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .action, text: "Some text"))
        let editor = ScreenplayEditor(document: document)
        
        await editor.updateBlock(at: 0, text: "INT. LOCATION - DAY")
        
        let element = await editor.element(at: 0)
        let text = await editor.text(at: 0)
        
        XCTAssertEqual(element, .sceneHeading)
        XCTAssertEqual(text, "INT. LOCATION - DAY")
    }
    
    func testUpdateBlockTextPreservesElementIfDetectionFails() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. OLD LOCATION"))
        let editor = ScreenplayEditor(document: document)
        
        await editor.updateBlock(at: 0, text: "new text")
        
        // Should preserve original element if new text doesn't match a pattern
        let element = await editor.element(at: 0)
        let text = await editor.text(at: 0)
        
        XCTAssertEqual(element, .sceneHeading)
        XCTAssertEqual(text, "new text")
    }
    
    // MARK: - Insert at End
    
    func testInsertBlockAtEndAppends() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. FIRST"))
        let editor = ScreenplayEditor(document: document)
        
        await editor.insertBlock(text: "INT. SECOND", at: 1)
        
        let count = await editor.blockCount()
        let element = await editor.element(at: 1)
        let text = await editor.text(at: 1)
        
        XCTAssertEqual(count, 2)
        XCTAssertEqual(element, .sceneHeading)
        XCTAssertEqual(text, "INT. SECOND")
    }
    
    // MARK: - Insert in Middle
    
    func testInsertBlockInMiddleShiftsSubsequentBlocks() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. FIRST"))
        document.appendBlock(ScreenplayBlock(element: .action, text: "Action"))
        let editor = ScreenplayEditor(document: document)
        
        await editor.insertBlock(text: "INT. INSERTED", at: 1)
        
        let count = await editor.blockCount()
        let element1 = await editor.element(at: 1)
        let text1 = await editor.text(at: 1)
        let text2 = await editor.text(at: 2)
        
        XCTAssertEqual(count, 3)
        XCTAssertEqual(element1, .sceneHeading)
        XCTAssertEqual(text1, "INT. INSERTED")
        XCTAssertEqual(text2, "Action")
    }
    
    // MARK: - Timestamp Updates
    
    func testInsertBlockUpdatesTimestamp() async {
        let document = ScreenplayDocument()
        let originalUpdatedAt = document.updatedAt
        let editor = ScreenplayEditor(document: document)
        
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        await editor.insertBlock(text: "INT. LOCATION", at: 0)
        
        let updatedAt = await editor.documentUpdatedAt()
        XCTAssertGreaterThan(updatedAt, originalUpdatedAt)
    }
    
    func testUpdateBlockTextUpdatesTimestamp() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .action, text: "old"))
        let originalUpdatedAt = document.updatedAt
        let editor = ScreenplayEditor(document: document)
        
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        await editor.updateBlock(at: 0, text: "new")
        
        let updatedAt = await editor.documentUpdatedAt()
        XCTAssertGreaterThan(updatedAt, originalUpdatedAt)
    }
    
    // MARK: - Edge Cases
    
    func testInsertBlockWithEmptyTextDefaultsToAction() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.insertBlock(text: "", at: 0)
        
        let element = await editor.element(at: 0)
        let text = await editor.text(at: 0)
        
        XCTAssertEqual(element, .action)
        XCTAssertEqual(text, "")
    }
    
    func testInsertBlockWithWhitespaceOnlyDefaultsToAction() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.insertBlock(text: "   ", at: 0)
        
        let element = await editor.element(at: 0)
        let text = await editor.text(at: 0)
        
        XCTAssertEqual(element, .action)
        XCTAssertEqual(text, "   ")
    }
}
