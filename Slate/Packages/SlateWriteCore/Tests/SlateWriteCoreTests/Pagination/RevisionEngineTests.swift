import Foundation
import Testing
@testable import SlateWriteCore

@Suite("Revision Engine")
struct RevisionEngineTests {

    @Test("Standard pages without revisions")
    func standardPages() {
        var blocks: [ScreenplayBlock] = []
        for i in 0..<60 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line \(i)."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        let revisionSet = RevisionSet(name: "First Revision", color: .blue)
        let revisionPages = RevisionEngine.applyRevisions(pages, lockedPages: [], currentRevisionSet: revisionSet)
        
        #expect(revisionPages.count == pages.count)
        #expect(revisionPages.allSatisfy { $0.revisionLetter == nil })
        #expect(revisionPages.allSatisfy { $0.lockStatus == .unlocked })
    }

    @Test("Locked pages create A-pages")
    func lockedPagesCreateAPages() {
        var blocks: [ScreenplayBlock] = []
        for i in 0..<60 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line \(i)."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Lock page 1
        let lockedPages: Set<Int> = [1]
        let revisionSet = RevisionSet(name: "First Revision", color: .blue)
        let revisionPages = RevisionEngine.applyRevisions(pages, lockedPages: lockedPages, currentRevisionSet: revisionSet)
        
        #expect(revisionPages.count == pages.count)
        #expect(revisionPages[0].pageNumber == "1A")
        #expect(revisionPages[0].revisionLetter == "A")
        #expect(revisionPages[0].lockStatus == .locked(revisionSetId: revisionSet.id))
    }

    @Test("Multiple locked pages create multiple A-pages")
    func multipleLockedPages() {
        var blocks: [ScreenplayBlock] = []
        for i in 0..<60 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line \(i)."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Lock pages 1 and 2
        let lockedPages: Set<Int> = [1, 2]
        let revisionSet = RevisionSet(name: "First Revision", color: .blue)
        let revisionPages = RevisionEngine.applyRevisions(pages, lockedPages: lockedPages, currentRevisionSet: revisionSet)
        
        #expect(revisionPages.count == pages.count)
        #expect(revisionPages[0].pageNumber == "1A")
        #expect(revisionPages[1].pageNumber == "2A")
        #expect(revisionPages[0].revisionLetter == "A")
        #expect(revisionPages[1].revisionLetter == "A")
    }

    @Test("Unlocked pages remain standard")
    func unlockedPagesStandard() {
        var blocks: [ScreenplayBlock] = []
        for i in 0..<60 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line \(i)."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        let pages = PaginationEngine.paginate(doc)
        
        // Lock only page 1
        let lockedPages: Set<Int> = [1]
        let revisionSet = RevisionSet(name: "First Revision", color: .blue)
        let revisionPages = RevisionEngine.applyRevisions(pages, lockedPages: lockedPages, currentRevisionSet: revisionSet)
        
        #expect(revisionPages.count == pages.count)
        #expect(revisionPages[0].pageNumber == "1A")
        #expect(revisionPages[1].pageNumber == "2") // Page 2 should be standard
        #expect(revisionPages[1].revisionLetter == nil)
    }

    @Test("Lock page functionality")
    func lockPage() {
        var lockedPages: Set<Int> = []
        lockedPages = RevisionEngine.lockPage(1, lockedPages: lockedPages)
        
        #expect(lockedPages.contains(1))
        #expect(lockedPages.count == 1)
        
        lockedPages = RevisionEngine.lockPage(2, lockedPages: lockedPages)
        
        #expect(lockedPages.contains(1))
        #expect(lockedPages.contains(2))
        #expect(lockedPages.count == 2)
    }

    @Test("Unlock page functionality")
    func unlockPage() {
        var lockedPages: Set<Int> = [1, 2, 3]
        lockedPages = RevisionEngine.unlockPage(2, lockedPages: lockedPages)
        
        #expect(lockedPages.contains(1))
        #expect(!lockedPages.contains(2))
        #expect(lockedPages.contains(3))
        #expect(lockedPages.count == 2)
    }

    @Test("Revision colors have display names")
    func revisionColorDisplayNames() {
        #expect(RevisionColor.blue.displayName == "Blue")
        #expect(RevisionColor.pink.displayName == "Pink")
        #expect(RevisionColor.yellow.displayName == "Yellow")
        #expect(RevisionColor.green.displayName == "Green")
        #expect(RevisionColor.goldenrod.displayName == "Goldenrod")
        #expect(RevisionColor.buff.displayName == "Buff")
        #expect(RevisionColor.salmon.displayName == "Salmon")
        #expect(RevisionColor.cherry.displayName == "Cherry")
    }

    @Test("Revision colors have hex values")
    func revisionColorHexValues() {
        #expect(RevisionColor.blue.hexColor == "#0000FF")
        #expect(RevisionColor.pink.hexColor == "#FFC0CB")
        #expect(RevisionColor.yellow.hexColor == "#FFFF00")
        #expect(RevisionColor.green.hexColor == "#008000")
    }

    @Test("Standard revision colors in order")
    func standardColorsOrder() {
        let standardColors = RevisionSet.standardColors
        #expect(standardColors.count == 8)
        #expect(standardColors[0] == .blue)
        #expect(standardColors[1] == .pink)
        #expect(standardColors[2] == .yellow)
        #expect(standardColors[3] == .green)
    }

    @Test("Pages to regenerate respects locked pages")
    func pagesToRegenerateRespectsLocks() {
        var blocks: [ScreenplayBlock] = []
        for i in 0..<120 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line \(i) with some additional text to ensure it spans multiple lines per block."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        
        // Build block to page map
        let (_, cache) = PaginationEngine.paginateIncremental(doc, fromBlock: 0)
        let blockToPageMap = cache.blockToPageMap
        
        // Lock pages 2 and 4
        let lockedPages: Set<Int> = [2, 4]
        
        // Edit block on page 3
        let editedBlockIndex = 60 // Assume this is on page 3
        let pagesToRegenerate = RevisionEngine.pagesToRegenerate(
            editedBlockIndex: editedBlockIndex,
            blockToPageMap: blockToPageMap,
            lockedPages: lockedPages
        )
        
        // Should regenerate page 3 but stop at locked page 4
        #expect(!pagesToRegenerate.contains(2))
        #expect(pagesToRegenerate.contains(3))
        #expect(!pagesToRegenerate.contains(4))
    }

    @Test("Edited locked page only regenerates that page")
    func editedLockedPageOnlyRegeneratesThatPage() {
        var blocks: [ScreenplayBlock] = []
        for i in 0..<120 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line \(i) with some additional text to ensure it spans multiple lines per block."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        
        // Build block to page map
        let (_, cache) = PaginationEngine.paginateIncremental(doc, fromBlock: 0)
        let blockToPageMap = cache.blockToPageMap
        
        // Lock page 2
        let lockedPages: Set<Int> = [2]
        
        // Edit block on page 2
        let editedBlockIndex = 30 // Assume this is on page 2
        let pagesToRegenerate = RevisionEngine.pagesToRegenerate(
            editedBlockIndex: editedBlockIndex,
            blockToPageMap: blockToPageMap,
            lockedPages: lockedPages
        )
        
        // Should only regenerate page 2
        #expect(pagesToRegenerate.count == 1)
        #expect(pagesToRegenerate.contains(2))
    }

    @Test("Revision set has unique ID")
    func revisionSetUniqueID() {
        let set1 = RevisionSet(name: "First", color: .blue)
        let set2 = RevisionSet(name: "Second", color: .pink)
        
        #expect(set1.id != set2.id)
    }

    @Test("Revision page base number extraction")
    func revisionPageBaseNumber() {
        let standardPage = RevisionPage.standard(5, lines: [])
        #expect(standardPage.baseNumber == 5)
        #expect(standardPage.pageNumber == "5")
        
        let aPage = RevisionPage.aPage(baseNumber: 5, lines: [], revisionSetId: UUID())
        #expect(aPage.baseNumber == 5)
        #expect(aPage.pageNumber == "5A")
    }
}
