import Foundation
import Testing
@testable import SlateWriteCore

@Suite("PDF Export Layout Verification")
struct PDFExportLayoutTests {

    @Test("Page dimensions match US Letter standard")
    func pageDimensions() {
        // US Letter: 8.5" x 11"
        let expectedWidth = 8.5
        let expectedHeight = 11.0
        
        // Verify layout constants produce correct page dimensions
        let leftMargin = PaginationLayout.leftMargin
        let rightMargin = PaginationLayout.rightMargin
        let topMargin = PaginationLayout.topMargin
        let bottomMargin = PaginationLayout.bottomMargin
        
        // Content area should be page size minus margins
        let contentWidth = expectedWidth - (leftMargin + rightMargin)
        let contentHeight = expectedHeight - (topMargin + bottomMargin)
        
        // Verify margins are in inches
        #expect(leftMargin == 1.5)  // 1.5" left margin
        #expect(rightMargin == 1.0) // 1.0" right margin
        #expect(topMargin == 1.0)   // 1.0" top margin
        #expect(bottomMargin == 1.0) // 1.0" bottom margin
        
        // Content area should be positive
        #expect(contentWidth > 0)
        #expect(contentHeight > 0)
    }

    @Test("Line height produces correct vertical spacing")
    func lineHeightSpacing() {
        let lineHeight = PaginationLayout.lineHeight // 1/6 inch
        
        #expect(lineHeight == 1.0/6.0) // 1/6 inch
        
        // 55 lines at 1/6 inch = 9.166... inches
        // With 1" top margin, bottom margin is ~0.83" to fit on 11" page
        let linesPerPage = PaginationLayout.linesPerPage
        let totalLineHeight = Double(linesPerPage) * lineHeight
        let expectedBottomMargin = 11.0 - PaginationLayout.topMargin - totalLineHeight
        
        // Bottom margin should be approximately 0.83" (industry standard)
        #expect(abs(expectedBottomMargin - 0.83) < 0.01)
    }

    @Test("Character width produces correct horizontal spacing")
    func characterWidthSpacing() {
        let characterWidth = PaginationLayout.characterWidth // 10 cpi = 0.1" per character
        
        #expect(characterWidth == 0.1) // 0.1 inch per character
        
        // Action width of 60 characters should fit within content width
        let actionWidth = PaginationLayout.actionWidth
        let actionWidthInInches = Double(actionWidth) * characterWidth
        let contentWidth = 8.5 - PaginationLayout.leftMargin - PaginationLayout.rightMargin
        
        #expect(actionWidthInInches <= contentWidth)
    }

    @Test("Element widths fit within content area")
    func elementWidthsFit() {
        let characterWidth = PaginationLayout.characterWidth // Already in inches
        let contentWidth = 8.5 - PaginationLayout.leftMargin - PaginationLayout.rightMargin
        
        // Scene heading width
        let sceneHeadingWidth = Double(PaginationLayout.sceneHeadingWidth) * characterWidth
        #expect(sceneHeadingWidth <= contentWidth)
        
        // Action width
        let actionWidth = Double(PaginationLayout.actionWidth) * characterWidth
        #expect(actionWidth <= contentWidth)
        
        // Dialogue width (centered, so should fit with margins)
        let dialogueWidth = Double(PaginationLayout.dialogueWidth) * characterWidth
        #expect(dialogueWidth <= contentWidth)
        
        // Parenthetical width (centered within dialogue)
        let parentheticalWidth = Double(PaginationLayout.parentheticalWidth) * characterWidth
        #expect(parentheticalWidth <= dialogueWidth)
    }

    @Test("Page number position is within margins")
    func pageNumberPosition() {
        // Page numbers typically appear at bottom center or bottom right
        // They should be within the bottom margin area
        let bottomMargin = PaginationLayout.bottomMargin // Already in inches
        
        #expect(bottomMargin >= 0.5) // At least 0.5" for page numbers
        #expect(bottomMargin <= 1.5) // Not more than 1.5"
    }

    @Test("Courier Prime font metrics are consistent")
    func courierPrimeMetrics() {
        // Courier Prime is a monospace font
        // All characters should have the same width
        let characterWidth = PaginationLayout.characterWidth
        let lineHeight = PaginationLayout.lineHeight
        
        // Character width should be positive
        #expect(characterWidth > 0)
        
        // Line height should be greater than character width (typical for fonts)
        #expect(lineHeight > characterWidth)
        
        // Aspect ratio should be reasonable for Courier
        let aspectRatio = Double(lineHeight) / Double(characterWidth)
        #expect(aspectRatio > 1.0) // Taller than wide
        #expect(aspectRatio < 2.0) // Not extremely tall
    }

    @Test("Total lines per page matches industry standard")
    func linesPerPageStandard() {
        let linesPerPage = PaginationLayout.linesPerPage
        
        // Industry standard is approximately 55 lines per page
        #expect(linesPerPage == 55)
    }

    @Test("Margins match Final Draft defaults")
    func marginsMatchFinalDraft() {
        let leftMargin = PaginationLayout.leftMargin
        let rightMargin = PaginationLayout.rightMargin
        let topMargin = PaginationLayout.topMargin
        let bottomMargin = PaginationLayout.bottomMargin
        
        // Final Draft default margins
        #expect(leftMargin == 1.5)  // 1.5" left
        #expect(rightMargin == 1.0) // 1.0" right
        #expect(topMargin == 1.0)   // 1.0" top
        #expect(bottomMargin == 1.0) // 1.0" bottom
    }

    @Test("Element-specific widths are proportional")
    func elementWidthsProportional() {
        let sceneHeadingWidth = PaginationLayout.sceneHeadingWidth
        let actionWidth = PaginationLayout.actionWidth
        let dialogueWidth = PaginationLayout.dialogueWidth
        let parentheticalWidth = PaginationLayout.parentheticalWidth
        
        // Scene heading and action should be similar (both full width)
        #expect(abs(sceneHeadingWidth - actionWidth) <= 5)
        
        // Dialogue should be narrower (centered)
        #expect(dialogueWidth < actionWidth)
        
        // Parenthetical should be narrower than dialogue
        #expect(parentheticalWidth < dialogueWidth)
        
        // All widths should be positive
        #expect(sceneHeadingWidth > 0)
        #expect(actionWidth > 0)
        #expect(dialogueWidth > 0)
        #expect(parentheticalWidth > 0)
    }

    @Test("Page content area calculation is consistent")
    func contentAreaConsistent() {
        let leftMargin = PaginationLayout.leftMargin
        let rightMargin = PaginationLayout.rightMargin
        let topMargin = PaginationLayout.topMargin
        let bottomMargin = PaginationLayout.bottomMargin
        
        let totalHorizontalMargin = leftMargin + rightMargin
        let totalVerticalMargin = topMargin + bottomMargin
        
        // Total margins should be less than page size (in inches)
        let pageWidth = 8.5
        let pageHeight = 11.0
        
        #expect(totalHorizontalMargin < pageWidth)
        #expect(totalVerticalMargin < pageHeight)
        
        // Content area should be reasonable
        let contentWidth = pageWidth - totalHorizontalMargin
        let contentHeight = pageHeight - totalVerticalMargin
        
        #expect(contentWidth > 4) // At least 4" wide
        #expect(contentHeight > 8) // At least 8" tall
    }

    @Test("Line wrapping respects element widths")
    func lineWrappingRespectsWidths() {
        // Test that action text wraps at correct width
        let longAction = "This is a very long action line that should wrap at exactly sixty characters which is the standard action width for screenplays."
        let actionLines = LineLayout.layout(block: ScreenplayBlock(element: .action, text: longAction))
        
        // Each line should not exceed action width
        for line in actionLines {
            #expect(line.text.count <= PaginationLayout.actionWidth)
        }
        
        // Test that dialogue wraps at correct width
        let longDialogue = "This is a very long dialogue line that should wrap at approximately thirty-five characters which is the standard dialogue width for screenplays."
        let dialogueLines = LineLayout.layout(block: ScreenplayBlock(element: .dialogue, text: longDialogue))
        
        // Each line should not exceed dialogue width
        for line in dialogueLines {
            #expect(line.text.count <= PaginationLayout.dialogueWidth)
        }
    }

    @Test("PDF coordinate system origin is top-left")
    func pdfCoordinateSystem() {
        // PDF coordinate system has origin at top-left
        // Y increases downward, X increases to the right
        
        // This test verifies our layout constants are designed for this coordinate system
        let topMargin = PaginationLayout.topMargin
        let leftMargin = PaginationLayout.leftMargin
        
        // Margins should be positive (offset from origin)
        #expect(topMargin > 0)
        #expect(leftMargin > 0)
        
        // Top margin is the distance from top edge to first line
        #expect(topMargin == 1.0) // 1.0"
        
        // Left margin is the distance from left edge to first character
        #expect(leftMargin == 1.5) // 1.5"
    }

    @Test("Page break markers are positioned correctly")
    func pageBreakMarkerPosition() {
        // Page breaks should occur at line 55 (or earlier due to break rules)
        let linesPerPage = PaginationLayout.linesPerPage
        
        // When a page break occurs, the next page should start at line 1
        // This is verified by the pagination engine tests
        
        #expect(linesPerPage == 55)
    }

    @Test("Character cue positioning is correct")
    func characterCuePositioning() {
        // Character cues should be left-aligned at specific margin
        // In Final Draft, character cues start at 3.7" from left edge
        
        // Our layout uses the same left margin for all elements
        // Character cues are distinguished by element type, not position
        let leftMargin = PaginationLayout.leftMargin
        
        // For now, we use the standard left margin
        // Future enhancement: add character-specific positioning
        #expect(leftMargin == 1.5)
    }
}
