import Foundation

/// A version snapshot of a document for autosave and manual versioning.
public struct VersionSnapshot: Codable, Sendable, Equatable {
    /// The snapshot name (user-provided or "Autosave" for automatic snapshots)
    public let name: String
    /// The document state at the time of the snapshot
    public let document: ScreenplayDocument
    /// When the snapshot was created
    public let createdAt: Date
    
    public init(name: String, document: ScreenplayDocument, createdAt: Date = .now) {
        self.name = name
        self.document = document
        self.createdAt = createdAt
    }
}

/// A scene in a screenplay for navigation purposes.
public struct Scene: Codable, Sendable, Equatable {
    /// The full scene heading text
    public let heading: String
    /// The extracted location name (e.g., "COFFEE SHOP")
    public let location: String
    /// The time of day (e.g., "DAY", "NIGHT")
    public let timeOfDay: String
    /// The block index where this scene starts
    public let blockIndex: Int
    
    public init(heading: String, location: String, timeOfDay: String, blockIndex: Int) {
        self.heading = heading
        self.location = location
        self.timeOfDay = timeOfDay
        self.blockIndex = blockIndex
    }
}

/// In-memory screenplay document — canonical editing model for SLATE Write.
public struct ScreenplayDocument: Codable, Sendable, Equatable {
    public var titlePage: TitlePage
    public var blocks: [ScreenplayBlock]
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        titlePage: TitlePage = TitlePage(),
        blocks: [ScreenplayBlock] = [],
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.titlePage = titlePage
        self.blocks = blocks
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Lossless plain-text dump for M0 verification (content only, no Fountain syntax).
    public func plainTextDump() -> String {
        var lines: [String] = []
        for block in blocks {
            switch block.element {
            case .pageBreak:
                lines.append("")
            case .section:
                lines.append(block.text.uppercased())
            case .synopsis:
                lines.append(block.text)
            default:
                lines.append(block.text)
            }
        }
        return lines.joined(separator: "\n")
    }

    /// Scene headings for navigator (E6-S1).
    public var scenes: [(index: Int, heading: String)] {
        blocks.enumerated().compactMap { index, block in
            guard block.element == .sceneHeading else { return nil }
            return (index, block.text)
        }
    }

    public mutating func appendBlock(_ block: ScreenplayBlock) {
        blocks.append(block)
        updatedAt = .now
    }
}
