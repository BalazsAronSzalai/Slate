import XCTest
@testable import SlateWriteCore

final class ElementAutoDetectionTests: XCTestCase {
    
    // MARK: - Scene Heading Detection
    
    func testINT_PrefixDetectsSceneHeading() {
        let text = "INT. COFFEE SHOP - DAY"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .sceneHeading)
    }
    
    func testEXT_PrefixDetectsSceneHeading() {
        let text = "EXT. PARKING LOT - NIGHT"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .sceneHeading)
    }
    
    func testINT_Slash_EXT_DetectsSceneHeading() {
        let text = "INT./EXT. HOUSE - DAY"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .sceneHeading)
    }
    
    func testEST_PrefixDetectsSceneHeading() {
        let text = "EST. NEW YORK CITY - DAY"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .sceneHeading)
    }
    
    func testINT_Slash_EST_DetectsSceneHeading() {
        let text = "INT./EST. APARTMENT - NIGHT"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .sceneHeading)
    }
    
    // MARK: - Transition Detection
    
    func testAllCapsWithColonDetectsTransition() {
        let text = "CUT TO:"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .transition)
    }
    
    func testFADE_OUTDetectsTransition() {
        let text = "FADE OUT:"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .transition)
    }
    
    func testDISSOLVE_TO_DetectsTransition() {
        let text = "DISSOLVE TO:"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .transition)
    }
    
    func testAllCapsWithColonInMiddleDetectsTransition() {
        let text = "SMASH CUT TO:"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .transition)
    }
    
    // MARK: - Character Detection
    
    func testAllCapsWithoutColonDetectsCharacter() {
        let text = "JOHN"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .character)
    }
    
    func testAllCapsWithSpaceDetectsCharacter() {
        let text = "JOHN DOE"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .character)
    }
    
    func testCharacterWithParentheticalDetectsCharacter() {
        let text = "JOHN (V.O.)"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .character)
    }
    
    func testCharacterWithContinuingDetectsCharacter() {
        let text = "JOHN (CONT'D)"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .character)
    }
    
    // MARK: - Parenthetical Detection
    
    func testParentheticalDetectsParenthetical() {
        let text = "(whispering)"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .parenthetical)
    }
    
    func testParentheticalWithTextDetectsParenthetical() {
        let text = "(beat)"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .parenthetical)
    }
    
    func testParentheticalWithComplexTextDetectsParenthetical() {
        let text = "(looking around nervously)"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .parenthetical)
    }
    
    // MARK: - Forced Page Break Detection
    
    func testTripleEqualsDetectsPageBreak() {
        let text = "==="
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .pageBreak)
    }
    
    func testTripleEqualsWithSpacesDetectsPageBreak() {
        let text = "   ===   "
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .pageBreak)
    }
    
    // MARK: - Centered Text Detection
    
    func testGreaterThanSignDetectsCentered() {
        let text = "> CENTERED TEXT"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .centered)
    }
    
    func testDoubleGreaterThanDetectsCentered() {
        let text = ">> CENTERED TEXT"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .centered)
    }
    
    // MARK: - Section/Synopsis Detection
    
    func testHashDetectsSection() {
        let text = "# ACT ONE"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .section)
    }
    
    func testDoubleHashDetectsSection() {
        let text = "## SCENE A"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .section)
    }
    
    func testTripleHashDetectsSynopsis() {
        let text = "### This is a synopsis"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .synopsis)
    }
    
    // MARK: - Default to Action
    
    func testMixedCaseDetectsAction() {
        let text = "John walks into the room."
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .action)
    }
    
    func testEmptyStringDefaultsToAction() {
        let text = ""
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .action)
    }
    
    func testDialogueTextDefaultsToAction() {
        let text = "I don't know what to do."
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .action)
    }
    
    // MARK: - Edge Cases
    
    func testINT_InMiddleDoesNotDetectSceneHeading() {
        let text = "He walks into the INT. room"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .action)
    }
    
    func testLowercaseIntDoesNotDetectSceneHeading() {
        let text = "int. coffee shop - day"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .action)
    }
    
    func testAllCapsWithoutColonButWithINT_DetectsSceneHeading() {
        let text = "INT. COFFEE SHOP - DAY"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .sceneHeading)
    }
    
    func testTransitionWithoutColonDoesNotDetectTransition() {
        let text = "CUT TO"
        let detected = ScreenplayElement.detect(from: text)
        XCTAssertEqual(detected, .character)
    }
}
