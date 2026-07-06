import Foundation

/// Represents a revision set with associated color and metadata.
public struct RevisionSet: Sendable, Equatable, Identifiable {
    public let id: UUID
    public let name: String
    public let color: RevisionColor
    public let createdAt: Date
    
    public init(id: UUID = UUID(), name: String, color: RevisionColor, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.color = color
        self.createdAt = createdAt
    }
    
    /// Standard revision colors in industry order
    public static let standardColors: [RevisionColor] = [
        .blue, .pink, .yellow, .green, .goldenrod, .buff, .salmon, .cherry
    ]
}

/// Industry-standard revision colors for screenplay revisions.
public enum RevisionColor: String, Sendable, Equatable, CaseIterable {
    case blue = "blue"
    case pink = "pink"
    case yellow = "yellow"
    case green = "green"
    case goldenrod = "goldenrod"
    case buff = "buff"
    case salmon = "salmon"
    case cherry = "cherry"
    
    /// Display name for the revision color
    public var displayName: String {
        switch self {
        case .blue: return "Blue"
        case .pink: return "Pink"
        case .yellow: return "Yellow"
        case .green: return "Green"
        case .goldenrod: return "Goldenrod"
        case .buff: return "Buff"
        case .salmon: return "Salmon"
        case .cherry: return "Cherry"
        }
    }
    
    /// Hex color representation for UI rendering
    public var hexColor: String {
        switch self {
        case .blue: return "#0000FF"
        case .pink: return "#FFC0CB"
        case .yellow: return "#FFFF00"
        case .green: return "#008000"
        case .goldenrod: return "#DAA520"
        case .buff: return "#F0DC82"
        case .salmon: return "#FA8072"
        case .cherry: return "#DE3163"
        }
    }
}

/// Represents a page lock status to prevent renumbering during revisions.
public enum PageLockStatus: Sendable, Equatable {
    case unlocked
    case locked(revisionSetId: UUID)
}

/// Represents a page with revision information.
public struct RevisionPage: Sendable, Equatable {
    public let pageNumber: String  // Can be "1", "1A", "1B", etc.
    public let baseNumber: Int     // The base page number (1 for "1A")
    public let revisionLetter: String? // "A", "B", etc., or nil
    public let lines: [Line]
    public let lockStatus: PageLockStatus
    public let revisionSetId: UUID? // Which revision set this page belongs to
    
    public init(
        pageNumber: String,
        baseNumber: Int,
        revisionLetter: String? = nil,
        lines: [Line],
        lockStatus: PageLockStatus = .unlocked,
        revisionSetId: UUID? = nil
    ) {
        self.pageNumber = pageNumber
        self.baseNumber = baseNumber
        self.revisionLetter = revisionLetter
        self.lines = lines
        self.lockStatus = lockStatus
        self.revisionSetId = revisionSetId
    }
    
    /// Create a standard page without revision
    public static func standard(_ number: Int, lines: [Line]) -> RevisionPage {
        return RevisionPage(
            pageNumber: "\(number)",
            baseNumber: number,
            revisionLetter: nil,
            lines: lines,
            lockStatus: .unlocked,
            revisionSetId: nil
        )
    }
    
    /// Create an A-page (first revision of a locked page)
    public static func aPage(baseNumber: Int, lines: [Line], revisionSetId: UUID) -> RevisionPage {
        return RevisionPage(
            pageNumber: "\(baseNumber)A",
            baseNumber: baseNumber,
            revisionLetter: "A",
            lines: lines,
            lockStatus: .locked(revisionSetId: revisionSetId),
            revisionSetId: revisionSetId
        )
    }
}

/// Revision engine that manages page locking, A-pages, and revision colors.
public enum RevisionEngine {
    
    /// Apply revision tracking to paginated pages.
    /// - Parameters:
    ///   - pages: The paginated pages from PaginationEngine
    ///   - lockedPages: Set of base page numbers that are locked
    ///   - currentRevisionSet: The active revision set
    /// - Returns: Array of RevisionPage with proper A-page numbering
    public static func applyRevisions(
        _ pages: [Page],
        lockedPages: Set<Int>,
        currentRevisionSet: RevisionSet
    ) -> [RevisionPage] {
        var revisionPages: [RevisionPage] = []
        var usedRevisionLetters: [Int: [String]] = [:] // Track used letters per base page
        
        for page in pages {
            let baseNumber = page.pageNumber
            
            if lockedPages.contains(baseNumber) {
                // This page is locked, create an A-page
                let letter = nextAvailableLetter(for: baseNumber, used: usedRevisionLetters[baseNumber] ?? [])
                usedRevisionLetters[baseNumber, default: []].append(letter)
                
                let revisionPage = RevisionPage(
                    pageNumber: "\(baseNumber)\(letter)",
                    baseNumber: baseNumber,
                    revisionLetter: letter,
                    lines: page.lines,
                    lockStatus: .locked(revisionSetId: currentRevisionSet.id),
                    revisionSetId: currentRevisionSet.id
                )
                revisionPages.append(revisionPage)
            } else {
                // Standard page
                let revisionPage = RevisionPage.standard(baseNumber, lines: page.lines)
                revisionPages.append(revisionPage)
            }
        }
        
        return revisionPages
    }
    
    /// Lock a specific page to prevent renumbering.
    /// - Parameters:
    ///   - pageNumber: The page number to lock
    ///   - lockedPages: Current set of locked pages
    /// - Returns: Updated set of locked pages
    public static func lockPage(_ pageNumber: Int, lockedPages: Set<Int>) -> Set<Int> {
        var updated = lockedPages
        updated.insert(pageNumber)
        return updated
    }
    
    /// Unlock a specific page to allow renumbering.
    /// - Parameters:
    ///   - pageNumber: The page number to unlock
    ///   - lockedPages: Current set of locked pages
    /// - Returns: Updated set of locked pages
    public static func unlockPage(_ pageNumber: Int, lockedPages: Set<Int>) -> Set<Int> {
        var updated = lockedPages
        updated.remove(pageNumber)
        return updated
    }
    
    /// Get the next available revision letter for a page.
    private static func nextAvailableLetter(for baseNumber: Int, used: [String]) -> String {
        let letters = ["A", "B", "C", "D", "E", "F", "G", "H"]
        for letter in letters {
            if !used.contains(letter) {
                return letter
            }
        }
        // If we exhaust standard letters, continue with AA, AB, etc.
        var counter = 1
        while true {
            for letter in letters {
                let composite = "\(letter)\(counter > 1 ? String(counter) : "")"
                if !used.contains(composite) {
                    return composite
                }
            }
            counter += 1
        }
    }
    
    /// Calculate which pages need to be regenerated based on edits.
    /// - Parameters:
    ///   - editedBlockIndex: The index of the edited block
    ///   - blockToPageMap: Mapping from block index to page number
    ///   - lockedPages: Set of locked page numbers
    /// - Returns: Set of page numbers that need repagination
    public static func pagesToRegenerate(
        editedBlockIndex: Int,
        blockToPageMap: [Int: Int],
        lockedPages: Set<Int>
    ) -> Set<Int> {
        guard let editedPage = blockToPageMap[editedBlockIndex] else {
            return []
        }
        
        // If the edited page is locked, we only need to regenerate that page (as an A-page)
        if lockedPages.contains(editedPage) {
            return [editedPage]
        }
        
        // If the page is unlocked, we need to regenerate from this page forward
        // until we hit a locked page
        var pagesToRegenerate: Set<Int> = []
        
        // Find all pages from edited page onward
        let allPages = Set(blockToPageMap.values).sorted()
        
        for page in allPages {
            if page >= editedPage {
                if lockedPages.contains(page) {
                    // Stop at locked page
                    break
                }
                pagesToRegenerate.insert(page)
            }
        }
        
        return pagesToRegenerate
    }
}
