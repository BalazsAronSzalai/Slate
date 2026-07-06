import Foundation
import Testing
@testable import SlateWriteCore

@Suite("Layout Constants")
struct LayoutConstantsTests {

    @Test("Courier Prime character width is 10 cpi")
    func characterWidth() {
        #expect(PaginationLayout.characterWidth == 0.1) // 10 characters per inch
    }

    @Test("Line height is exactly 12pt (1/6 inch)")
    func lineHeight() {
        #expect(PaginationLayout.lineHeight == 0.16666666666666666) // 12pt = 1/6 inch
    }

    @Test("Lines per page is 55 content lines")
    func linesPerPage() {
        #expect(PaginationLayout.linesPerPage == 55)
    }

    @Test("Left margin is 1.5 inches")
    func leftMargin() {
        #expect(PaginationLayout.leftMargin == 1.5)
    }

    @Test("Right margin is 1.0 inches")
    func rightMargin() {
        #expect(PaginationLayout.rightMargin == 1.0)
    }

    @Test("Top margin is 1.0 inches")
    func topMargin() {
        #expect(PaginationLayout.topMargin == 1.0)
    }

    @Test("Scene heading width is 60 characters")
    func sceneHeadingWidth() {
        #expect(PaginationLayout.sceneHeadingWidth == 60)
    }

    @Test("Action width is 60 characters")
    func actionWidth() {
        #expect(PaginationLayout.actionWidth == 60)
    }

    @Test("Dialogue width is approximately 35 characters")
    func dialogueWidth() {
        #expect(PaginationLayout.dialogueWidth == 35)
    }

    @Test("Parenthetical width is approximately 26 characters")
    func parentheticalWidth() {
        #expect(PaginationLayout.parentheticalWidth == 26)
    }
}
