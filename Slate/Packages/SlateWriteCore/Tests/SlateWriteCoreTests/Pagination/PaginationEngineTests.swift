import Foundation
import Testing
@testable import SlateWriteCore

@Suite("Pagination Engine")
struct PaginationEngineTests {

    @Test("Empty document produces one page")
    func emptyDocument() {
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: [])
        let pages = PaginationEngine.paginate(doc)
        #expect(pages.count == 1)
        #expect(pages.first?.lines.isEmpty == true)
    }

    @Test("Single scene heading fits on one page")
    func singleSceneHeading() {
        let doc = ScreenplayDocument(
            titlePage: TitlePage(),
            blocks: [
                ScreenplayBlock(element: .sceneHeading, text: "INT. KITCHEN - NIGHT")
            ]
        )
        let pages = PaginationEngine.paginate(doc)
        #expect(pages.count == 1)
        #expect(pages.first?.lines.count == 1)
    }

    @Test("55 lines of action exactly fill one page")
    func fullPageOfAction() {
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<55 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        #expect(pages.count == 1)
        #expect(pages.first?.lines.count == 55)
    }

    @Test("56 lines of action create second page")
    func overflowToSecondPage() {
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<56 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        #expect(pages.count == 2)
        #expect(pages[0].lines.count == 55)
        #expect(pages[1].lines.count == 1)
    }

    @Test("Page count is accurate for multi-page document")
    func multiPageDocument() {
        var blocks: [ScreenplayBlock] = []
        for _ in 0..<120 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        #expect(pages.count == 3)
        #expect(pages[0].lines.count == 55)
        #expect(pages[1].lines.count == 55)
        #expect(pages[2].lines.count == 10)
    }

    @Test("Scene heading followed by action")
    func sceneThenAction() {
        let doc = ScreenplayDocument(
            titlePage: TitlePage(),
            blocks: [
                ScreenplayBlock(element: .sceneHeading, text: "INT. KITCHEN - NIGHT"),
                ScreenplayBlock(element: .action, text: "A kettle whistles.")
            ]
        )
        let pages = PaginationEngine.paginate(doc)
        #expect(pages.count == 1)
        #expect(pages.first?.lines.count == 2)
    }

    @Test("Dialogue block produces multiple lines")
    func dialogueBlock() {
        let longDialogue = String(repeating: "WORD ", count: 10)
        let doc = ScreenplayDocument(
            titlePage: TitlePage(),
            blocks: [
                ScreenplayBlock(element: .character, text: "JOHN"),
                ScreenplayBlock(element: .dialogue, text: longDialogue)
            ]
        )
        let pages = PaginationEngine.paginate(doc)
        #expect(pages.count == 1)
        #expect((pages.first?.lines.count ?? 0) > 2) // Character + wrapped dialogue
    }
}
