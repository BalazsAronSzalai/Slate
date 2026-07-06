import Foundation

public struct FountainParseReport: Sendable, Equatable {
    public var warnings: [String]
    public var linesImportedAsAction: Int

    public init(warnings: [String] = [], linesImportedAsAction: Int = 0) {
        self.warnings = warnings
        self.linesImportedAsAction = linesImportedAsAction
    }
}

/// Fountain 1.1 import parser (FR-04, §3.8). Never fails — ambiguous lines degrade to Action.
public enum FountainParser {

    public static func parse(_ source: String) -> (ScreenplayDocument, FountainParseReport) {
        var report = FountainParseReport()
        let normalized = normalize(source)
        let rawLines = normalized.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

        var index = 0
        let (titlePage, titleEnd) = parseTitlePage(lines: rawLines, start: 0)
        index = titleEnd

        var blocks: [ScreenplayBlock] = []
        var pendingNotes: [String] = []
        var inDialogue = false
        var lastCharacterBlockIndex: Int?

        while index < rawLines.count {
            var line = rawLines[index]

            // Boneyard skip
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("/*") {
                index = skipBoneyard(lines: rawLines, from: index)
                continue
            }

            // Multiline note-only line
            if let note = extractLeadingNote(from: &line) {
                pendingNotes.append(note)
                if line.isEmpty {
                    index += 1
                    continue
                }
            }

            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty {
                inDialogue = false
                lastCharacterBlockIndex = nil
                index += 1
                continue
            }

            // Page break
            if trimmed == "===" {
                appendBlock(
                    ScreenplayBlock(element: .pageBreak, text: "==="),
                    notes: pendingNotes,
                    to: &blocks
                )
                pendingNotes = []
                inDialogue = false
                index += 1
                continue
            }

            let (element, text, dualColumn) = classifyLine(
                trimmed,
                inDialogue: inDialogue,
                report: &report
            )

            switch element {
            case .character:
                inDialogue = true
                lastCharacterBlockIndex = blocks.count
            case .dialogue, .parenthetical:
                inDialogue = true
            case .sceneHeading, .action, .transition, .section, .synopsis, .pageBreak:
                inDialogue = false
                lastCharacterBlockIndex = nil
            default:
                break
            }

            appendBlock(
                ScreenplayBlock(
                    element: element,
                    text: text,
                    dualDialogueColumn: dualColumn
                ),
                notes: pendingNotes,
                to: &blocks
            )
            pendingNotes = []
            index += 1
        }

        let document = ScreenplayDocument(titlePage: titlePage, blocks: blocks)
        return (document, report)
    }

    // MARK: - Title page

    private static func parseTitlePage(lines: [String], start: Int) -> (TitlePage, Int) {
        var fields: [String: String] = [:]
        var index = start

        while index < lines.count {
            let line = lines[index]
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if fields.isEmpty {
                    index += 1
                    continue
                }
                return (TitlePage(fields: fields), index + 1)
            }

            guard let colon = line.firstIndex(of: ":") else {
                if fields.isEmpty { return (TitlePage(), start) }
                break
            }

            let key = String(line[..<colon]).trimmingCharacters(in: .whitespaces)
            let value = String(line[line.index(after: colon)...]).trimmingCharacters(in: .whitespaces)
            guard !key.isEmpty else { break }
            fields[key] = value
            index += 1
        }

        if fields.isEmpty { return (TitlePage(), start) }
        return (TitlePage(fields: fields), index)
    }

    // MARK: - Classification

    private static func classifyLine(
        _ line: String,
        inDialogue: Bool,
        report: inout FountainParseReport
    ) -> (ScreenplayElement, String, Int?) {
        var working = line
        var dualColumn: Int?

        if working.hasSuffix("^") {
            working.removeLast()
            dualColumn = 0
        }

        // Forced prefixes (Fountain spec)
        if working.hasPrefix(".") {
            return (.sceneHeading, String(working.dropFirst()).trimmingCharacters(in: .whitespaces), dualColumn)
        }
        if working.hasPrefix("!") {
            return (.action, String(working.dropFirst()).trimmingCharacters(in: .whitespaces), dualColumn)
        }
        if working.hasPrefix("@") {
            return (.character, String(working.dropFirst()).trimmingCharacters(in: .whitespaces), dualColumn)
        }
        if working.hasPrefix("> ") {
            return (.centered, String(working.dropFirst(2)).trimmingCharacters(in: .whitespaces), dualColumn)
        }
        if working.hasPrefix(">") {
            return (.transition, String(working.dropFirst()).trimmingCharacters(in: .whitespaces), dualColumn)
        }
        if working.hasPrefix("# ") {
            return (.section, String(working.dropFirst(2)), dualColumn)
        }
        if working.hasPrefix("#") && working.hasSuffix("#") && working.count > 2 {
            // Scene number marker on heading: INT. HOUSE #8#
            let inner = String(working.dropFirst().dropLast())
            if isSceneHeading(inner) {
                return (.sceneHeading, stripSceneNumber(from: inner).text, dualColumn)
            }
        }
        if working.hasPrefix("#") {
            return (.section, String(working.dropFirst()), dualColumn)
        }
        if working.hasPrefix("=") {
            return (.synopsis, String(working.dropFirst()).trimmingCharacters(in: .whitespaces), dualColumn)
        }
        if working.hasPrefix("~") {
            return (.lyric, String(working.dropFirst()).trimmingCharacters(in: .whitespaces), dualColumn)
        }

        if inDialogue {
            if working.hasPrefix("(") && working.hasSuffix(")") {
                return (.parenthetical, working, dualColumn)
            }
            return (.dialogue, working, dualColumn)
        }

        if isSceneHeading(working) {
            let stripped = stripSceneNumber(from: working)
            return (.sceneHeading, stripped.text, dualColumn)
        }

        if isTransition(working) {
            return (.transition, working, dualColumn)
        }

        if isCharacterCue(working) {
            return (.character, working, dualColumn)
        }

        report.linesImportedAsAction += 1
        return (.action, working, dualColumn)
    }

    private static func isSceneHeading(_ line: String) -> Bool {
        let upper = line.uppercased()
        let prefixes = ["INT.", "EXT.", "INT./EXT.", "I/E.", "EST."]
        return prefixes.contains { upper.hasPrefix($0) }
    }

    private static func isTransition(_ line: String) -> Bool {
        let upper = line.uppercased().trimmingCharacters(in: .whitespaces)
        guard upper == line.trimmingCharacters(in: .whitespaces) else { return false }
        return upper.hasSuffix(" TO:") || upper == "FADE OUT." || upper == "FADE IN:" || upper.hasSuffix(":")
    }

    private static func isCharacterCue(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed == line else { return false }
        guard !trimmed.isEmpty, trimmed.count <= 40 else { return false }
        let letters = trimmed.filter(\.isLetter)
        guard !letters.isEmpty else { return false }
        return trimmed == trimmed.uppercased() && !trimmed.hasSuffix(":")
    }

    private static func stripSceneNumber(from line: String) -> (text: String, number: String?) {
        guard let start = line.firstIndex(of: "#") else { return (line, nil) }
        let after = line.index(after: start)
        guard after < line.endIndex, let end = line[after...].firstIndex(of: "#") else {
            return (line, nil)
        }
        let number = String(line[after..<end])
        var text = String(line[..<start]) + String(line[line.index(after: end)...])
        text = text.trimmingCharacters(in: .whitespaces)
        return (text, number)
    }

    // MARK: - Helpers

    private static func normalize(_ source: String) -> String {
        var text = source
        if text.hasPrefix("\u{FEFF}") { text.removeFirst() }
        text = text.replacingOccurrences(of: "\r\n", with: "\n")
        text = text.replacingOccurrences(of: "\r", with: "\n")
        return text
    }

    private static func extractLeadingNote(from line: inout String) -> String? {
        guard let start = line.range(of: "[[") else { return nil }
        guard let end = line.range(of: "]]", range: start.upperBound..<line.endIndex) else { return nil }
        let note = String(line[start.upperBound..<end.lowerBound])
        line.removeSubrange(start.lowerBound..<end.upperBound)
        line = line.trimmingCharacters(in: .whitespaces)
        return note
    }

    private static func skipBoneyard(lines: [String], from index: Int) -> Int {
        var i = index
        while i < lines.count {
            if lines[i].contains("*/") { return i + 1 }
            i += 1
        }
        return lines.count
    }

    private static func appendBlock(
        _ block: ScreenplayBlock,
        notes: [String],
        to blocks: inout [ScreenplayBlock]
    ) {
        var block = block
        block.inlineNotes = notes
        blocks.append(block)
    }
}
