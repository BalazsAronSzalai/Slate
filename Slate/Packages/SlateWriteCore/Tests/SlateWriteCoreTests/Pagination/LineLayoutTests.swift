import Foundation
import Testing
@testable import SlateWriteCore

@Suite("Line Layout")
struct LineLayoutTests {

    @Test("Scene heading fits within 60 characters")
    func sceneHeadingFits() {
        let block = ScreenplayBlock(element: .sceneHeading, text: "INT. KITCHEN - NIGHT")
        let lines = LineLayout.layout(block: block)
        #expect(lines.count == 1)
        #expect(lines.first?.text == "INT. KITCHEN - NIGHT")
        #expect(lines.first?.element == .sceneHeading)
    }

    @Test("Long action text wraps at 60 characters")
    func actionWrapping() {
        let longText = String(repeating: "WORD ", count: 15) // 75 characters
        let block = ScreenplayBlock(element: .action, text: longText)
        let lines = LineLayout.layout(block: block)
        #expect(lines.count > 1)
        #expect(lines.allSatisfy { $0.element == .action })
        #expect(lines.allSatisfy { $0.text.count <= 60 })
    }

    @Test("Dialogue wraps at 35 characters")
    func dialogueWrapping() {
        let longDialogue = String(repeating: "WORD ", count: 10) // 50 characters
        let block = ScreenplayBlock(element: .dialogue, text: longDialogue)
        let lines = LineLayout.layout(block: block)
        #expect(lines.count > 1)
        #expect(lines.allSatisfy { $0.element == .dialogue })
        #expect(lines.allSatisfy { $0.text.count <= 35 })
    }

    @Test("Parenthetical wraps at 26 characters")
    func parentheticalWrapping() {
        let longParenthetical = String(repeating: "WORD ", count: 8) // 40 characters
        let block = ScreenplayBlock(element: .parenthetical, text: longParenthetical)
        let lines = LineLayout.layout(block: block)
        #expect(lines.count > 1)
        #expect(lines.allSatisfy { $0.element == .parenthetical })
        #expect(lines.allSatisfy { $0.text.count <= 26 })
    }

    @Test("Character cue does not wrap")
    func characterNoWrap() {
        let block = ScreenplayBlock(element: .character, text: "VERY_LONG_CHARACTER_NAME_THAT_EXCEEDS_WIDTH")
        let lines = LineLayout.layout(block: block)
        #expect(lines.count == 1)
        #expect(lines.first?.element == .character)
    }

    @Test("Empty block produces no lines")
    func emptyBlock() {
        let block = ScreenplayBlock(element: .action, text: "")
        let lines = LineLayout.layout(block: block)
        #expect(lines.isEmpty)
    }

    @Test("Transition is right-aligned")
    func transitionAlignment() {
        let block = ScreenplayBlock(element: .transition, text: "CUT TO:")
        let lines = LineLayout.layout(block: block)
        #expect(lines.count == 1)
        #expect(lines.first?.element == .transition)
        #expect(lines.first?.alignment == .right)
    }

    @Test("Scene heading is left-aligned")
    func sceneHeadingAlignment() {
        let block = ScreenplayBlock(element: .sceneHeading, text: "INT. KITCHEN - NIGHT")
        let lines = LineLayout.layout(block: block)
        #expect(lines.count == 1)
        #expect(lines.first?.alignment == .left)
    }
}
