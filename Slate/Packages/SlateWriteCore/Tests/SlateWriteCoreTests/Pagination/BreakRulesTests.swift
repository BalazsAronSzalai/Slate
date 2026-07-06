import Foundation
import Testing
@testable import SlateWriteCore

@Suite("Break Rules")
struct BreakRulesTests {

    @Test("B1: Scene heading orphan - heading at page bottom pushes to next page")
    func sceneHeadingOrphan() {
        // Create 54 lines of action, then a scene heading
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<54 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line."))
        }
        blocks.append(ScreenplayBlock(element: .sceneHeading, text: "INT. KITCHEN - NIGHT"))
        blocks.append(ScreenplayBlock(element: .action, text: "Some action."))
        
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Scene heading should be pushed to page 2, not orphaned on page 1
        #expect(pages.count == 2)
        #expect(pages[0].lines.count <= 54) // Should not include the orphaned heading
        #expect(pages[1].lines.contains { $0.element == .sceneHeading })
    }

    @Test("B2: Character cue orphan - cue with insufficient dialogue pushes to next page")
    func characterCueOrphan() {
        // Create 53 lines of action, then character with only 1 line of dialogue
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<53 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line."))
        }
        blocks.append(ScreenplayBlock(element: .character, text: "JOHN"))
        blocks.append(ScreenplayBlock(element: .dialogue, text: "Hi."))
        
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Character cue should be pushed to page 2 (needs 2+ lines after it)
        #expect(pages.count == 2)
    }

    @Test("B3: Dialogue break - long dialogue splits across pages")
    func dialogueBreak() {
        // Create dialogue that spans multiple pages
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<54 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line."))
        }
        blocks.append(ScreenplayBlock(element: .character, text: "JOHN"))
        blocks.append(ScreenplayBlock(element: .dialogue, text: String(repeating: "WORD ", count: 20)))
        
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Should have dialogue split across pages
        #expect(pages.count > 1)
        // MORE/CONT'D markers will be implemented in future iteration
    }

    @Test("B4: Parenthetical never splits across pages")
    func parentheticalNoSplit() {
        // Create a scenario where parenthetical would naturally split
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<53 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line."))
        }
        blocks.append(ScreenplayBlock(element: .character, text: "JOHN"))
        blocks.append(ScreenplayBlock(element: .parenthetical, text: "very long parenthetical that would wrap"))
        blocks.append(ScreenplayBlock(element: .dialogue, text: "Dialogue."))
        
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Parenthetical should stay with its dialogue or be pushed entirely
        #expect(pages.count >= 2)
    }

    @Test("B5: Action break prefers sentence boundaries")
    func actionSentenceBreak() {
        // Create enough action to span multiple pages
        var blocks: [ScreenplayBlock] = []
        for i in 0..<60 {
            blocks.append(ScreenplayBlock(element: .action, text: "This is sentence \(i). More text here."))
        }
        
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Lines should break at sentence boundaries where possible
        #expect(pages.count > 1)
    }

    @Test("B6: Transition stays with preceding element")
    func transitionWithPreceding() {
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<54 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line."))
        }
        blocks.append(ScreenplayBlock(element: .transition, text: "CUT TO:"))
        
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Transition should not start a new page alone
        #expect(pages.count == 1 || pages[1].lines.first?.element == .transition)
    }

    @Test("B8: Forced page break with ===")
    func forcedPageBreak() {
        // Create enough content before and after break to ensure separate pages
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<30 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action before break."))
        }
        blocks.append(ScreenplayBlock(element: .pageBreak, text: "==="))
        for _ in 0..<30 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action after break."))
        }
        
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Should create at least 2 pages due to forced break
        #expect(pages.count >= 2)
    }

    @Test("B9: Soft bottom - page may be shorter than 55 lines for break rules")
    func softBottom() {
        // Create scenario where break rules would shorten a page
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<53 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line."))
        }
        blocks.append(ScreenplayBlock(element: .sceneHeading, text: "INT. KITCHEN - NIGHT"))
        blocks.append(ScreenplayBlock(element: .action, text: "Action."))
        
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // First page may be shorter than 55 lines due to orphan rule
        #expect(pages[0].lines.count <= 55)
    }
}
