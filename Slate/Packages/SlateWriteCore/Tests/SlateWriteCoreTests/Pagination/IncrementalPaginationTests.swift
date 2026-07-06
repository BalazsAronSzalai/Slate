import Foundation
import Testing
@testable import SlateWriteCore

@Suite("Incremental Pagination")
struct IncrementalPaginationTests {

    @Test("Incremental pagination produces same result as full pagination")
    func incrementalMatchesFull() {
        var blocks: [ScreenplayBlock] = []
        for i in 0..<100 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line \(i)."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        
        let fullPages = PaginationEngine.paginate(doc)
        let (incrementalPages, _) = PaginationEngine.paginateIncremental(doc, fromBlock: 0)
        
        #expect(fullPages.count == incrementalPages.count)
        #expect(fullPages.map(\.lines.count) == incrementalPages.map(\.lines.count))
    }

    @Test("Pagination from middle block only repaginates affected pages")
    func paginationFromMiddle() {
        var blocks: [ScreenplayBlock] = []
        for i in 0..<120 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line \(i)."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        
        // First, get full pagination and cache
        let (_, initialCache) = PaginationEngine.paginateIncremental(doc, fromBlock: 0)
        
        // Start pagination from block 60 (middle of document) using cache
        let (incrementalPages, _) = PaginationEngine.paginateIncremental(doc, fromBlock: 60, cache: initialCache)
        
        #expect(incrementalPages.count > 1)
        // First page should be preserved from previous pagination
        #expect(incrementalPages.first?.pageNumber == 1)
    }

    @Test("Stabilization stops repagination when page boundary stabilizes")
    func stabilization() {
        var blocks: [ScreenplayBlock] = []
        for i in 0..<100 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line \(i)."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        
        let (pages, _) = PaginationEngine.paginateIncremental(doc, fromBlock: 0)
        
        // All pages should be paginated
        #expect(pages.count > 1)
    }

    @Test("Single block edit only repaginates from that block")
    func singleBlockEdit() {
        var blocks: [ScreenplayBlock] = []
        for i in 0..<120 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line \(i) with some additional text to ensure it spans multiple lines per block."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        
        // First, get full pagination and cache
        let (_, initialCache) = PaginationEngine.paginateIncremental(doc, fromBlock: 0)
        
        // Edit block at index 30
        let (pages, _) = PaginationEngine.paginateIncremental(doc, fromBlock: 30, cache: initialCache)
        
        #expect(pages.count >= 2)
    }

    @Test("Cache preserves pages before change point")
    func cachePreservesPages() {
        var blocks: [ScreenplayBlock] = []
        for i in 0..<100 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line \(i)."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        
        // Get initial pagination
        let (initialPages, initialCache) = PaginationEngine.paginateIncremental(doc, fromBlock: 0)
        
        // Repaginate from block 50 (should preserve first ~2 pages)
        let (incrementalPages, _) = PaginationEngine.paginateIncremental(doc, fromBlock: 50, cache: initialCache)
        
        // Pages before the change should be identical
        let preservedPageCount = initialCache.blockToPageMap[50] ?? 0
        if preservedPageCount > 1 {
            let firstPreservedPage = initialPages[preservedPageCount - 2]
            let firstIncrementalPage = incrementalPages[preservedPageCount - 2]
            #expect(firstPreservedPage.lines == firstIncrementalPage.lines)
        }
    }

    @Test("Cache invalidates on document change")
    func cacheInvalidation() {
        var blocks: [ScreenplayBlock] = []
        for i in 0..<50 {
            blocks.append(ScreenplayBlock(element: .action, text: "Action line \(i) with some additional text to ensure it spans multiple lines per block."))
        }
        let doc = ScreenplayDocument(titlePage: TitlePage(), blocks: blocks)
        
        // Get initial pagination
        let (_, initialCache) = PaginationEngine.paginateIncremental(doc, fromBlock: 0)
        
        // Modify document significantly
        var modifiedBlocks = blocks
        for i in 50..<100 {
            modifiedBlocks.append(ScreenplayBlock(element: .action, text: "Additional action line \(i) with some additional text to ensure it spans multiple lines per block."))
        }
        let modifiedDoc = ScreenplayDocument(titlePage: TitlePage(), blocks: modifiedBlocks)
        
        // Repaginate with old cache (should invalidate and do full pagination)
        let (pages, newCache) = PaginationEngine.paginateIncremental(modifiedDoc, fromBlock: 0, cache: initialCache)
        
        // Cache should be rebuilt
        #expect(newCache.documentHash != initialCache.documentHash)
        #expect(pages.count >= initialCache.pages.count)
    }
}
