import Foundation

/// Represents a single page in the paginated screenplay.
public struct Page: Sendable, Equatable {
    public let pageNumber: Int
    public let lines: [Line]
    
    public init(pageNumber: Int, lines: [Line]) {
        self.pageNumber = pageNumber
        self.lines = lines
    }
}

/// Cache for incremental pagination optimization.
/// Stores the previous pagination result to enable fast repagination.
public struct PaginationCache: Sendable, Equatable {
    /// The cached pages from the last pagination
    public let pages: [Page]
    /// Mapping from block index to the page number it starts on
    public let blockToPageMap: [Int: Int]
    /// The document hash this cache is based on
    public let documentHash: Int
    
    public init(pages: [Page], blockToPageMap: [Int: Int], documentHash: Int) {
        self.pages = pages
        self.blockToPageMap = blockToPageMap
        self.documentHash = documentHash
    }
    
    /// Create an empty cache
    public static let empty = PaginationCache(pages: [], blockToPageMap: [:], documentHash: 0)
}

/// Pagination engine that converts a screenplay document into pages.
/// Implements greedy line-filling with industry-standard break rules.
public enum PaginationEngine {
    
    /// Paginate a screenplay document into pages.
    /// - Parameter document: The screenplay document to paginate
    /// - Returns: Array of pages with line breaks applied
    public static func paginate(_ document: ScreenplayDocument) -> [Page] {
        // Convert all blocks to lines
        var allLines: [Line] = []
        for block in document.blocks {
            allLines.append(contentsOf: LineLayout.layout(block: block))
        }
        
        // Apply break rules and paginate
        return paginateWithBreakRules(allLines)
    }
    
    /// Incrementally paginate starting from a specific block index.
    /// This is used for performance optimization when editing - only repaginate
    /// from the point of change forward.
    /// - Parameters:
    ///   - document: The screenplay document to paginate
    ///   - fromBlock: The block index to start repagination from (0-based)
    ///   - cache: Optional cache from previous pagination
    /// - Returns: Tuple of (pages, newCache) with line breaks applied
    public static func paginateIncremental(_ document: ScreenplayDocument, fromBlock: Int, cache: PaginationCache = .empty) -> ([Page], PaginationCache) {
        let currentHash = computeDocumentHash(document)
        
        // If cache is empty or document changed significantly, do full pagination
        if cache.pages.isEmpty || cache.documentHash != currentHash || fromBlock == 0 {
            let pages = paginate(document)
            let blockToPageMap = buildBlockToPageMap(document, pages: pages)
            let newCache = PaginationCache(pages: pages, blockToPageMap: blockToPageMap, documentHash: currentHash)
            return (pages, newCache)
        }
        
        // Find the page where the changed block starts
        guard let startPage = cache.blockToPageMap[fromBlock] else {
            // Block index not in cache, fall back to full pagination
            let pages = paginate(document)
            let blockToPageMap = buildBlockToPageMap(document, pages: pages)
            let newCache = PaginationCache(pages: pages, blockToPageMap: blockToPageMap, documentHash: currentHash)
            return (pages, newCache)
        }
        
        // Preserve pages before the change point
        let preservedPages = Array(cache.pages.prefix(startPage - 1))
        
        // Repaginate from the changed block
        let documentFromChange = ScreenplayDocument(
            titlePage: document.titlePage,
            blocks: Array(document.blocks[fromBlock...]),
            createdAt: document.createdAt,
            updatedAt: document.updatedAt
        )
        let repaginatedPages = paginate(documentFromChange)
        
        // Merge preserved pages with repaginated pages
        var mergedPages = preservedPages
        var currentPageNumber = preservedPages.count + 1
        
        for var page in repaginatedPages {
            page = Page(pageNumber: currentPageNumber, lines: page.lines)
            mergedPages.append(page)
            currentPageNumber += 1
        }
        
        // Build new cache
        let blockToPageMap = buildBlockToPageMap(document, pages: mergedPages)
        let newCache = PaginationCache(pages: mergedPages, blockToPageMap: blockToPageMap, documentHash: currentHash)
        
        return (mergedPages, newCache)
    }
    
    // MARK: - Cache Helpers
    
    /// Compute a hash of the document for cache validation.
    private static func computeDocumentHash(_ document: ScreenplayDocument) -> Int {
        var hasher = Hasher()
        hasher.combine(document.blocks.count)
        for block in document.blocks {
            hasher.combine(block.element)
            hasher.combine(block.text)
        }
        return hasher.finalize()
    }
    
    /// Build a mapping from block index to page number.
    private static func buildBlockToPageMap(_ document: ScreenplayDocument, pages: [Page]) -> [Int: Int] {
        var map: [Int: Int] = [:]
        var currentBlockIndex = 0
        var currentLineIndex = 0
        
        for page in pages {
            for line in page.lines {
                // Find which block this line belongs to
                while currentBlockIndex < document.blocks.count {
                    let block = document.blocks[currentBlockIndex]
                    let blockLines = LineLayout.layout(block: block)
                    
                    if currentLineIndex < blockLines.count {
                        if currentLineIndex == 0 {
                            // This is the first line of the block
                            map[currentBlockIndex] = page.pageNumber
                        }
                        currentLineIndex += 1
                        break
                    } else {
                        currentBlockIndex += 1
                        currentLineIndex = 0
                    }
                }
            }
        }
        
        return map
    }
    
    // MARK: - Break Rules Implementation
    
    private static func paginateWithBreakRules(_ lines: [Line]) -> [Page] {
        guard !lines.isEmpty else {
            return [Page(pageNumber: 1, lines: [])]
        }
        
        var pages: [Page] = []
        let linesPerPage = PaginationLayout.linesPerPage
        var currentPageNumber = 1
        var currentPageLines: [Line] = []
        var index = 0
        
        // Track dialogue state for MORE/CONT'D
        var activeCharacter: String? = nil
        var dialogueLinesOnCurrentPage = 0
        
        while index < lines.count {
            let line = lines[index]
            
            // Check for forced page break
            if line.element == .pageBreak {
                if !currentPageLines.isEmpty {
                    // Add MORE if dialogue was active
                    if let character = activeCharacter, dialogueLinesOnCurrentPage > 0 {
                        currentPageLines.append(Line(text: "(MORE)", element: .dialogue, alignment: .center))
                    }
                    pages.append(Page(pageNumber: currentPageNumber, lines: currentPageLines))
                    currentPageNumber += 1
                    currentPageLines = []
                    activeCharacter = nil
                    dialogueLinesOnCurrentPage = 0
                }
                index += 1
                continue
            }
            
            // Track character cues
            if line.element == .character {
                activeCharacter = line.text
                dialogueLinesOnCurrentPage = 0
            }
            
            // Track dialogue lines
            if line.element == .dialogue {
                dialogueLinesOnCurrentPage += 1
            }
            
            // Reset dialogue state when we hit a non-dialogue element
            if line.element != .character && line.element != .dialogue && line.element != .parenthetical {
                activeCharacter = nil
                dialogueLinesOnCurrentPage = 0
            }
            
            // Check if adding this line would exceed page limit
            if currentPageLines.count >= linesPerPage {
                // Add MORE if dialogue was active
                if let character = activeCharacter, dialogueLinesOnCurrentPage > 0 {
                    currentPageLines.append(Line(text: "(MORE)", element: .dialogue, alignment: .center))
                }
                
                pages.append(Page(pageNumber: currentPageNumber, lines: currentPageLines))
                currentPageNumber += 1
                currentPageLines = []
                
                // Add CONT'D on next page if dialogue was active
                if let character = activeCharacter {
                    currentPageLines.append(Line(text: "\(character) (CONT'D)", element: .character, alignment: .left))
                    dialogueLinesOnCurrentPage = 0
                }
            }
            
            // Apply break rules before adding line
            if shouldPushToNextPage(line, currentPageLines: currentPageLines, remainingLines: Array(lines[index...])) {
                // Add MORE if dialogue was active
                if let character = activeCharacter, dialogueLinesOnCurrentPage > 0 {
                    currentPageLines.append(Line(text: "(MORE)", element: .dialogue, alignment: .center))
                }
                
                if !currentPageLines.isEmpty {
                    pages.append(Page(pageNumber: currentPageNumber, lines: currentPageLines))
                    currentPageNumber += 1
                    currentPageLines = []
                    
                    // Add CONT'D on next page if dialogue was active
                    if let character = activeCharacter {
                        currentPageLines.append(Line(text: "\(character) (CONT'D)", element: .character, alignment: .left))
                        dialogueLinesOnCurrentPage = 0
                    }
                }
            }
            
            currentPageLines.append(line)
            index += 1
        }
        
        // Add remaining lines as final page
        if !currentPageLines.isEmpty {
            pages.append(Page(pageNumber: currentPageNumber, lines: currentPageLines))
        }
        
        return pages.isEmpty ? [Page(pageNumber: 1, lines: [])] : pages
    }
    
    /// Determines if a line should be pushed to the next page based on break rules.
    private static func shouldPushToNextPage(_ line: Line, currentPageLines: [Line], remainingLines: [Line]) -> Bool {
        let linesPerPage = PaginationLayout.linesPerPage
        let currentLineCount = currentPageLines.count
        let spaceRemaining = linesPerPage - currentLineCount
        
        // B1: Scene heading orphan - must have at least 1 line after it on same page
        if line.element == .sceneHeading && spaceRemaining < 2 {
            return true
        }
        
        // B2: Character cue orphan - must have at least 2 lines of dialogue after it
        if line.element == .character && spaceRemaining < 3 {
            // Check if there are at least 2 dialogue/parenthetical lines following
            let followingLines = remainingLines.dropFirst()
            let dialogueLinesCount = followingLines.prefix(3).filter { 
                $0.element == .dialogue || $0.element == .parenthetical 
            }.count
            if dialogueLinesCount < 2 {
                return true
            }
        }
        
        // B4: Parenthetical never splits - push if it would be at page bottom
        if line.element == .parenthetical && spaceRemaining < 2 {
            return true
        }
        
        // B6: Transition stays with preceding element
        if line.element == .transition && spaceRemaining < 1 && !currentPageLines.isEmpty {
            return true
        }
        
        return false
    }
}
