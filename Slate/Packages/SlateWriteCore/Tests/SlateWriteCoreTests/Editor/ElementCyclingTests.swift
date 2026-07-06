import XCTest
@testable import SlateWriteCore

final class ElementCyclingTests: XCTestCase {
    
    // MARK: - Tab Cycling (Forward)
    
    func testTabCyclesFromSceneHeadingToAction() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. LOCATION - DAY"))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .action)
    }
    
    func testTabCyclesFromActionToCharacter() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .action, text: "Some action description."))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .character)
    }
    
    func testTabCyclesFromCharacterToDialogue() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .character, text: "JOHN"))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .dialogue)
    }
    
    func testTabCyclesFromDialogueToParenthetical() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .dialogue, text: "Some dialogue text."))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .parenthetical)
    }
    
    func testTabCyclesFromParentheticalToDialogue() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .parenthetical, text: "(whispering)"))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .dialogue)
    }
    
    func testTabCyclesFromDialogueToTransition() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .dialogue, text: "Some dialogue text."))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .forward)
        editor.cycleElement(at: 0, direction: .forward) // dialogue -> parenthetical
        editor.cycleElement(at: 0, direction: .forward) // parenthetical -> dialogue
        editor.cycleElement(at: 0, direction: .forward) // dialogue -> transition
        
        XCTAssertEqual(document.blocks[0].element, .transition)
    }
    
    func testTabCyclesFromTransitionToSceneHeading() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .transition, text: "CUT TO:"))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .sceneHeading)
    }
    
    // MARK: - Enter Cycling (Backward)
    
    func testEnterCyclesFromSceneHeadingToTransition() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. LOCATION - DAY"))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .backward)
        
        XCTAssertEqual(document.blocks[0].element, .transition)
    }
    
    func testEnterCyclesFromActionToSceneHeading() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .action, text: "Some action description."))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .backward)
        
        XCTAssertEqual(document.blocks[0].element, .sceneHeading)
    }
    
    func testEnterCyclesFromCharacterToAction() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .character, text: "JOHN"))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .backward)
        
        XCTAssertEqual(document.blocks[0].element, .action)
    }
    
    func testEnterCyclesFromDialogueToCharacter() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .dialogue, text: "Some dialogue text."))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .backward)
        
        XCTAssertEqual(document.blocks[0].element, .character)
    }
    
    func testEnterCyclesFromParentheticalToCharacter() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .parenthetical, text: "(whispering)"))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .backward)
        
        XCTAssertEqual(document.blocks[0].element, .character)
    }
    
    func testEnterCyclesFromTransitionToDialogue() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .transition, text: "CUT TO:"))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .backward)
        
        XCTAssertEqual(document.blocks[0].element, .dialogue)
    }
    
    // MARK: - Edge Cases
    
    func testCyclingEmptyBlockDefaultsToSceneHeading() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .action, text: ""))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].element, .sceneHeading)
    }
    
    func testCyclingPreservesBlockText() {
        var document = ScreenplayDocument()
        let originalText = "INT. LOCATION - DAY"
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: originalText))
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertEqual(document.blocks[0].text, originalText)
    }
    
    func testCyclingUpdatesDocumentTimestamp() {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. LOCATION - DAY"))
        let originalUpdatedAt = document.updatedAt
        
        // Small delay to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.01)
        
        let editor = ScreenplayEditor(document: document)
        editor.cycleElement(at: 0, direction: .forward)
        
        XCTAssertGreaterThan(document.updatedAt, originalUpdatedAt)
    }
}
