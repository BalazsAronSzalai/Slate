import XCTest
@testable import SlateWriteCore

final class ElementCyclingTests: XCTestCase {
    
    // MARK: - Tab Cycling (Forward)
    
    func testTabCyclesFromSceneHeadingToAction() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. LOCATION - DAY"))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .action)
    }
    
    func testTabCyclesFromActionToCharacter() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .action, text: "Some action description."))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .character)
    }
    
    func testTabCyclesFromCharacterToDialogue() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .character, text: "JOHN"))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .dialogue)
    }
    
    func testTabCyclesFromDialogueToParenthetical() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .dialogue, text: "Some dialogue text."))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .parenthetical)
    }
    
    func testTabCyclesFromParentheticalToDialogue() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .parenthetical, text: "(whispering)"))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .dialogue)
    }
    
    func testTabCyclesFromDialogueToTransition() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .dialogue, text: "Some dialogue text."))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .forward)
        await editor.cycleElement(at: 0, direction: .forward) // dialogue -> parenthetical
        await editor.cycleElement(at: 0, direction: .forward) // parenthetical -> dialogue
        await editor.cycleElement(at: 0, direction: .forward) // dialogue -> transition
        
        XCTAssertEqual(document.blocks[0].element, .transition)
    }
    
    func testTabCyclesFromTransitionToSceneHeading() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .transition, text: "CUT TO:"))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .sceneHeading)
    }
    
    // MARK: - Enter Cycling (Backward)
    
    func testEnterCyclesFromSceneHeadingToTransition() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. LOCATION - DAY"))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .backward)
        
        XCTAssertEqual(document.blocks[0].element, .transition)
    }
    
    func testEnterCyclesFromActionToSceneHeading() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .action, text: "Some action description."))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .backward)
        
        XCTAssertEqual(document.blocks[0].element, .sceneHeading)
    }
    
    func testEnterCyclesFromCharacterToAction() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .character, text: "JOHN"))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .backward)
        
        XCTAssertEqual(document.blocks[0].element, .action)
    }
    
    func testEnterCyclesFromDialogueToCharacter() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .dialogue, text: "Some dialogue text."))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .backward)
        
        XCTAssertEqual(document.blocks[0].element, .character)
    }
    
    func testEnterCyclesFromParentheticalToCharacter() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .parenthetical, text: "(whispering)"))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .backward)
        
        XCTAssertEqual(document.blocks[0].element, .character)
    }
    
    func testEnterCyclesFromTransitionToDialogue() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .transition, text: "CUT TO:"))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .backward)
        
        XCTAssertEqual(document.blocks[0].element, .dialogue)
    }
    
    // MARK: - Edge Cases
    
    func testCyclingEmptyBlockDefaultsToSceneHeading() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .action, text: ""))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .sceneHeading)
    }
    
    func testCyclingPreservesBlockText() async {
        var document = ScreenplayDocument()
        let originalText = "INT. LOCATION - DAY"
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: originalText))
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].text, originalText)
    }
    
    func testCyclingUpdatesDocumentTimestamp() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. LOCATION - DAY"))
        let originalUpdatedAt = document.updatedAt
        
        // Small delay to ensure timestamp difference
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        let editor = ScreenplayEditor(document: document)
        await editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertGreaterThan(document.updatedAt, originalUpdatedAt)
    }
}
