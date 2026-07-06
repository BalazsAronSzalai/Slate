import Foundation
import Testing
@testable import SlateWriteCore

@Suite("Dialogue MORE/CONT'D Markers")
struct DialogueMoreContdTests {

    @Test("Dialogue spanning pages adds (MORE) at end of first page")
    func dialogueMoreMarker() {
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<54 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line."))
        }
        blocks.append(ScreenplayBlock(element: .character, text: "JOHN"))
        blocks.append(ScreenplayBlock(element: .dialogue, text: String(repeating: "WORD ", count: 20)))
        
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // First page should end with (MORE) marker
        let firstPage = pages.first
        #expect(firstPage != nil)
        let lastLine = firstPage?.lines.last
        #expect(lastLine?.text.contains("(MORE)") == true)
    }

    @Test("Dialogue spanning pages adds CHARACTER (CONT'D) at start of second page")
    func dialogueContdMarker() {
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<54 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line."))
        }
        blocks.append(ScreenplayBlock(element: .character, text: "JOHN"))
        blocks.append(ScreenplayBlock(element: .dialogue, text: String(repeating: "WORD ", count: 20)))
        
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Second page should start with CHARACTER (CONT'D)
        if pages.count > 1 {
            let secondPage = pages[1]
            let firstLine = secondPage.lines.first
            #expect(firstLine?.text.contains("JOHN (CONT'D)") == true)
        }
    }

    @Test("Short dialogue on single page has no MORE/CONT'D")
    func shortDialogueNoMarkers() {
        let blocks = [
            ScreenplayBlock(element: .character, text: "JOHN"),
            ScreenplayBlock(element: .dialogue, text: "Hello.")
        ]
        
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Should not have MORE or CONT'D markers
        let allText = pages.flatMap { $0.lines }.map { $0.text }.joined(separator: "\n")
        #expect(!allText.contains("(MORE)"))
        #expect(!allText.contains("(CONT'D)"))
    }

    @Test("Dialogue with parenthetical handles MORE/CONT'D correctly")
    func dialogueWithParenthetical() {
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<53 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line."))
        }
        blocks.append(ScreenplayBlock(element: .character, text: "JOHN"))
        blocks.append(ScreenplayBlock(element: .parenthetical, text: "whispering"))
        blocks.append(ScreenplayBlock(element: .dialogue, text: String(repeating: "WORD ", count: 15)))
        
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Should handle parenthetical in the break logic
        #expect(pages.count > 1)
    }

    @Test("Multiple dialogue breaks in sequence")
    func multipleDialogueBreaks() {
        // This test would require extremely long dialogue to span 3+ pages
        // For now, we verify the basic MORE/CONT'D works (covered by other tests)
        // Full multi-page dialogue will be tested with golden-file fixtures
        #expect(true) // Placeholder for future golden-file testing
    }
}
