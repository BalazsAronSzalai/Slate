import Foundation

/// Parses Fountain markup into a `ScreenplayDocument`.
///
/// Implements the core Fountain syntax: title pages, scene headings (with
/// scene numbers), action, character cues (with extensions and dual-dialogue
/// markers), dialogue, parentheticals, transitions, lyrics, sections,
/// synopses, page breaks, centered text, notes, boneyards, and the
/// forcing prefixes (`.` `!` `@` `>` `~`).
public enum FountainParser {
    public static func parse(_ text: String) -> ScreenplayDocument {
        let normalized = stripBoneyard(text.replacingOccurrences(of: "\r\n", with: "\n"))
        var lines = normalized.components(separatedBy: "\n")

        let titlePage = parseTitlePage(&lines)
        let elements = parseElements(lines)
        return ScreenplayDocument(titlePage: titlePage, elements: elements)
    }

    // MARK: - Boneyard

    private static func stripBoneyard(_ text: String) -> String {
        text.removingMultilineBoneyard()
    }

    // MARK: - Title page

    /// A title page is only recognized when the document opens with one of these
    /// well-known keys. This avoids misreading body text that merely contains a
    /// colon (e.g. `Bob turns: he sees nothing.`) as a title page. Once a title
    /// page is detected, subsequent entries may use arbitrary keys per the
    /// Fountain spec (e.g. `Producer: Jane Doe`).
    private static let titlePageKeys: Set<String> = [
        "title", "credit", "author", "authors", "source", "draft date",
        "date", "contact", "copyright", "notes", "revision",
    ]

    private static func parseTitlePage(_ lines: inout [String]) -> [TitlePageEntry] {
        guard let first = lines.first,
              let colon = first.firstIndex(of: ":"),
              titlePageKeys.contains(first[..<colon].lowercased())
        else { return [] }

        var entries: [TitlePageEntry] = []
        var index = 0
        while index < lines.count {
            let line = lines[index]
            if line.trimmingCharacters(in: .whitespaces).isEmpty { break }
            guard let colonIndex = line.firstIndex(of: ":"),
                  !line.hasPrefix(" "), !line.hasPrefix("\t"),
                  !line[..<colonIndex].trimmingCharacters(in: .whitespaces).isEmpty
            else { break }

            let key = String(line[..<colonIndex])
            var valueLines: [String] = []
            let inline = line[line.index(after: colonIndex)...].trimmingCharacters(in: .whitespaces)
            if !inline.isEmpty { valueLines.append(inline) }
            index += 1
            while index < lines.count, lines[index].hasPrefix("   ") || lines[index].hasPrefix("\t") {
                valueLines.append(lines[index].trimmingCharacters(in: .whitespaces))
                index += 1
            }
            entries.append(TitlePageEntry(key: key, value: valueLines.joined(separator: "\n")))
        }
        lines.removeFirst(index)
        return entries
    }

    // MARK: - Elements

    private static func parseElements(_ lines: [String]) -> [ScreenplayElement] {
        var elements: [ScreenplayElement] = []
        let blocks = splitIntoBlocks(lines)
        for block in blocks {
            elements.append(contentsOf: parseBlock(block))
        }
        markDualDialoguePartners(&elements)
        return elements
    }

    /// A `^`-marked character cue makes the immediately preceding dialogue
    /// block its dual-dialogue partner.
    private static func markDualDialoguePartners(_ elements: inout [ScreenplayElement]) {
        for index in elements.indices where
            elements[index].type == .character && elements[index].isDualDialogue {
            var cursor = index - 1
            while cursor >= 0, [.dialogue, .parenthetical].contains(elements[cursor].type) {
                cursor -= 1
            }
            guard cursor >= 0, elements[cursor].type == .character,
                  !elements[cursor].isDualDialogue else { continue }
            for partner in cursor..<index {
                elements[partner].isDualDialogue = true
            }
        }
    }

    private static func splitIntoBlocks(_ lines: [String]) -> [[String]] {
        var blocks: [[String]] = []
        var current: [String] = []
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces).isEmpty {
                if !current.isEmpty { blocks.append(current); current = [] }
            } else {
                current.append(line)
            }
        }
        if !current.isEmpty { blocks.append(current) }
        return blocks
    }

    private static func parseBlock(_ block: [String]) -> [ScreenplayElement] {
        guard let firstLine = block.first else { return [] }
        let trimmed = firstLine.trimmingCharacters(in: .whitespaces)

        // Page break: three or more '=' alone.
        if block.count == 1, trimmed.count >= 3, trimmed.allSatisfy({ $0 == "=" }) {
            return [ScreenplayElement(type: .pageBreak, text: "")]
        }

        // Forced markers that apply to whole single-purpose blocks.
        if trimmed.hasPrefix("#") {
            let depth = trimmed.prefix(while: { $0 == "#" }).count
            let text = String(trimmed.dropFirst(depth)).trimmingCharacters(in: .whitespaces)
            return [ScreenplayElement(type: .section, text: text, sectionDepth: depth)]
                + parseBlock(Array(block.dropFirst()))
        }
        if trimmed.hasPrefix("=") {
            let text = String(trimmed.dropFirst()).trimmingCharacters(in: .whitespaces)
            return [ScreenplayElement(type: .synopsis, text: text)]
                + parseBlock(Array(block.dropFirst()))
        }
        if trimmed.hasPrefix("~") {
            return block.map { line in
                ScreenplayElement(
                    type: .lyrics,
                    text: String(line.trimmingCharacters(in: .whitespaces).dropFirst())
                        .trimmingCharacters(in: .whitespaces)
                )
            }
        }
        if trimmed.hasPrefix("!") {
            let (text, notes) = extractNotes(
                block.enumerated()
                    .map { index, line in index == 0 ? String(trimmed.dropFirst()) : line }
                    .joined(separator: "\n")
            )
            return [ScreenplayElement(type: .action, text: text, notes: notes)]
        }
        if trimmed.hasPrefix(">") {
            let (stripped, notes) = extractNotes(trimmed)
            if stripped.hasSuffix("<") {
                let text = String(stripped.dropFirst().dropLast()).trimmingCharacters(in: .whitespaces)
                return [ScreenplayElement(type: .action, text: text, isCentered: true, notes: notes)]
            }
            let text = String(stripped.dropFirst()).trimmingCharacters(in: .whitespaces)
            return [ScreenplayElement(type: .transition, text: text, notes: notes)]
        }
        if trimmed.hasPrefix("."), !trimmed.hasPrefix("..") {
            let (text, sceneNumber) = extractSceneNumber(String(trimmed.dropFirst()))
            return [ScreenplayElement(type: .sceneHeading, text: text, sceneNumber: sceneNumber)]
        }
        if trimmed.hasPrefix("@") {
            return parseDialogueBlock(block, forcedCharacter: true)
        }

        // Scene heading.
        if block.count == 1, isSceneHeading(trimmed) {
            let (text, sceneNumber) = extractSceneNumber(trimmed)
            return [ScreenplayElement(type: .sceneHeading, text: text, sceneNumber: sceneNumber)]
        }

        // Transition: uppercase, ends in "TO:", alone in its block.
        if block.count == 1, trimmed.hasSuffix("TO:"), trimmed == trimmed.uppercased() {
            return [ScreenplayElement(type: .transition, text: trimmed)]
        }

        // Character cue: uppercase line followed by more lines in the block.
        if block.count > 1, isCharacterCue(trimmed) {
            return parseDialogueBlock(block, forcedCharacter: false)
        }

        // Action (default).
        let (text, notes) = extractNotes(block.joined(separator: "\n"))
        return [ScreenplayElement(type: .action, text: text, notes: notes)]
    }

    private static func parseDialogueBlock(
        _ block: [String],
        forcedCharacter: Bool
    ) -> [ScreenplayElement] {
        var cue = block[0].trimmingCharacters(in: .whitespaces)
        if forcedCharacter { cue = String(cue.dropFirst()) }
        var isDual = false
        if cue.hasSuffix("^") {
            isDual = true
            cue = String(cue.dropLast()).trimmingCharacters(in: .whitespaces)
        }
        var elements = [ScreenplayElement(type: .character, text: cue, isDualDialogue: isDual)]

        var dialogueLines: [String] = []
        func flushDialogue() {
            guard !dialogueLines.isEmpty else { return }
            elements.append(ScreenplayElement(
                type: .dialogue,
                text: dialogueLines.joined(separator: "\n"),
                isDualDialogue: isDual
            ))
            dialogueLines = []
        }
        for line in block.dropFirst() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("("), trimmed.hasSuffix(")") {
                flushDialogue()
                elements.append(ScreenplayElement(
                    type: .parenthetical, text: trimmed, isDualDialogue: isDual
                ))
            } else {
                dialogueLines.append(trimmed)
            }
        }
        flushDialogue()
        return elements
    }

    // MARK: - Line classification helpers

    private static let sceneHeadingPattern = #"^(?:INT\.?/EXT|EXT\.?/INT|INT|EXT|EST|I/E)[.\s]"#

    static func isSceneHeading(_ line: String) -> Bool {
        line.uppercased() == line
            && line.range(of: sceneHeadingPattern, options: [.regularExpression, .caseInsensitive]) != nil
            && line.range(of: sceneHeadingPattern, options: .regularExpression) != nil
    }

    static func isCharacterCue(_ line: String) -> Bool {
        var name = line
        if name.hasSuffix("^") { name = String(name.dropLast()).trimmingCharacters(in: .whitespaces) }
        if let parenIndex = name.firstIndex(of: "(") {
            name = String(name[..<parenIndex]).trimmingCharacters(in: .whitespaces)
        }
        guard !name.isEmpty, name.rangeOfCharacter(from: .letters) != nil else { return false }
        guard !name.hasSuffix(":") else { return false }
        return name == name.uppercased()
    }

    static func extractSceneNumber(_ line: String) -> (text: String, sceneNumber: String?) {
        guard let match = line.range(of: #"\s*#([0-9A-Za-z\.\-]+)#\s*$"#, options: .regularExpression)
        else { return (line, nil) }
        let numberPart = line[match]
            .trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let text = String(line[..<match.lowerBound]).trimmingCharacters(in: .whitespaces)
        return (text, numberPart)
    }

    static func extractNotes(_ text: String) -> (text: String, notes: [String]) {
        var notes: [String] = []
        var result = text
        while let range = result.range(of: #"(?s)\[\[.*?\]\]"#, options: .regularExpression) {
            let note = String(result[range].dropFirst(2).dropLast(2))
                .trimmingCharacters(in: .whitespaces)
            notes.append(note)
            result.removeSubrange(range)
        }
        return (result.trimmingCharacters(in: .whitespaces), notes)
    }
}

private extension String {
    /// Removes boneyard comments that span multiple lines.
    func removingMultilineBoneyard() -> String {
        guard contains("/*") else { return self }
        var output = ""
        var remainder = Substring(self)
        while let start = remainder.range(of: "/*") {
            output += remainder[..<start.lowerBound]
            if let end = remainder.range(of: "*/", range: start.upperBound..<remainder.endIndex) {
                remainder = remainder[end.upperBound...]
            } else {
                remainder = ""
            }
        }
        output += remainder
        return output
    }
}
