import Foundation

public struct FountainExportOptions: Sendable, Equatable {
    public var includeNotes: Bool
    public var includeSynopses: Bool
    public var includeSections: Bool
    public var includeSceneNumbers: Bool

    public init(
        includeNotes: Bool = false,
        includeSynopses: Bool = true,
        includeSections: Bool = true,
        includeSceneNumbers: Bool = false
    ) {
        self.includeNotes = includeNotes
        self.includeSynopses = includeSynopses
        self.includeSections = includeSections
        self.includeSceneNumbers = includeSceneNumbers
    }

    public static let `default` = FountainExportOptions()
}

/// Canonical Fountain serializer (§3.8 round-trip contract).
public enum FountainExporter {

    public static func export(
        _ document: ScreenplayDocument,
        options: FountainExportOptions = .default
    ) -> String {
        var lines: [String] = []

        if !document.titlePage.fields.isEmpty {
            for key in document.titlePage.fields.keys.sorted() {
                if let value = document.titlePage.fields[key] {
                    lines.append("\(key): \(value)")
                }
            }
            lines.append("")
        }

        for block in document.blocks {
            if !block.inlineNotes.isEmpty, options.includeNotes {
                for note in block.inlineNotes {
                    lines.append("[[\(note)]]")
                }
            }

            switch block.element {
            case .sceneHeading:
                var text = block.text
                if options.includeSceneNumbers, let number = block.sceneNumber {
                    text += " #\(number)#"
                }
                lines.append("." + text)
            case .action:
                lines.append(block.text)
            case .character:
                var line = "@" + block.text
                if block.dualDialogueColumn != nil { line += "^" }
                lines.append(line)
            case .dialogue:
                lines.append(block.text)
            case .parenthetical:
                lines.append(block.text)
            case .transition:
                lines.append(">" + block.text)
            case .shot:
                lines.append(block.text)
            case .general:
                lines.append(block.text)
            case .section where options.includeSections:
                lines.append("#" + block.text)
            case .synopsis where options.includeSynopses:
                lines.append("=" + block.text)
            case .pageBreak:
                lines.append("===")
            case .centered:
                lines.append("> " + block.text)
            case .lyric:
                lines.append("~" + block.text)
            case .section, .synopsis:
                continue
            }

            lines.append("")
        }

        while lines.last == "" { lines.removeLast() }
        return lines.joined(separator: "\n") + "\n"
    }
}

/// Round-trip helper used by tests and import pipelines.
public enum FountainRoundTrip {
    public static func exportThenParse(_ document: ScreenplayDocument) -> ScreenplayDocument {
        let fountain = FountainExporter.export(document)
        return FountainParser.parse(fountain).0
    }
}
