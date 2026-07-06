import Foundation

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
