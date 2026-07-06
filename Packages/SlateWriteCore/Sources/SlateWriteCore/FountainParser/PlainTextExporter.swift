import Foundation

/// Serializes a `ScreenplayDocument` back to Fountain-compatible plain text.
///
/// Output is written so that re-parsing it yields an equivalent document
/// (lossless round trip for all standard elements).
public enum PlainTextExporter {
    public static func export(_ document: ScreenplayDocument) -> String {
        var chunks: [String] = []

        if !document.titlePage.isEmpty {
            var titleLines: [String] = []
            for entry in document.titlePage {
                if entry.value.contains("\n") {
                    titleLines.append("\(entry.key):")
                    for line in entry.value.components(separatedBy: "\n") {
                        titleLines.append("    \(line)")
                    }
                } else {
                    titleLines.append("\(entry.key): \(entry.value)")
                }
            }
            chunks.append(titleLines.joined(separator: "\n"))
        }

        var pendingDualPartner = false
        var index = 0
        let elements = document.elements
        while index < elements.count {
            let element = elements[index]
            switch element.type {
            case .character:
                var lines = [renderCharacterCue(element, pendingDualPartner: &pendingDualPartner)]
                index += 1
                while index < elements.count,
                      [.dialogue, .parenthetical].contains(elements[index].type) {
                    lines.append(elements[index].text)
                    index += 1
                }
                chunks.append(lines.joined(separator: "\n"))
                continue
            case .sceneHeading:
                chunks.append(renderSceneHeading(element))
            case .action:
                chunks.append(renderAction(element))
            case .transition:
                let isStandard = element.text.hasSuffix("TO:")
                    && element.text == element.text.uppercased()
                chunks.append(isStandard ? element.text : "> \(element.text)")
            case .lyrics:
                chunks.append("~\(element.text)")
            case .section:
                chunks.append("\(String(repeating: "#", count: max(element.sectionDepth, 1))) \(element.text)")
            case .synopsis:
                chunks.append("= \(element.text)")
            case .pageBreak:
                chunks.append("===")
            case .shot:
                chunks.append(".\(element.text)")
            case .dialogue, .parenthetical:
                chunks.append(element.text) // orphaned dialogue degrades to action
            }
            if element.type != .character { pendingDualPartner = false }
            index += 1
        }

        return chunks.joined(separator: "\n\n")
    }

    private static func renderCharacterCue(
        _ element: ScreenplayElement,
        pendingDualPartner: inout Bool
    ) -> String {
        var cue = element.text
        if cue != cue.uppercased() || !FountainParser.isCharacterCue(cue) {
            cue = "@\(cue)"
        }
        if element.isDualDialogue {
            if pendingDualPartner {
                cue += " ^"
                pendingDualPartner = false
            } else {
                pendingDualPartner = true
            }
        } else {
            pendingDualPartner = false
        }
        return cue
    }

    private static func renderSceneHeading(_ element: ScreenplayElement) -> String {
        var line = FountainParser.isSceneHeading(element.text) ? element.text : ".\(element.text)"
        if let sceneNumber = element.sceneNumber {
            line += " #\(sceneNumber)#"
        }
        return line
    }

    private static func renderAction(_ element: ScreenplayElement) -> String {
        if element.isCentered {
            return "> \(element.text) <"
        }
        var text = element.text
        if !element.notes.isEmpty {
            text += " " + element.notes.map { "[[\($0)]]" }.joined(separator: " ")
        }
        let needsForcing = FountainParser.isSceneHeading(text)
            || text.hasPrefix(".") || text.hasPrefix("!") || text.hasPrefix("@")
            || text.hasPrefix(">") || text.hasPrefix("~") || text.hasPrefix("#")
            || text.hasPrefix("=")
            || (text.hasSuffix("TO:") && text == text.uppercased())
        return needsForcing && !text.hasPrefix("...") ? "!\(text)" : text
    }
}
