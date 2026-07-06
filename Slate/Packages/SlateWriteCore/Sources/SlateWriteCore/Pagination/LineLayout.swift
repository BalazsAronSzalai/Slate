import Foundation

/// Represents a single rendered line in the screenplay.
public struct Line: Sendable, Equatable {
    public let text: String
    public let element: ScreenplayElement
    public let alignment: TextAlignment
    
    public enum TextAlignment: Sendable, Equatable {
        case left
        case center
        case right
    }
    
    public init(text: String, element: ScreenplayElement, alignment: TextAlignment = .left) {
        self.text = text
        self.element = element
        self.alignment = alignment
    }
}

/// Layout engine that converts screenplay blocks into rendered lines.
public enum LineLayout {
    
    /// Layout a single block into lines according to element-specific rules.
    /// - Parameter block: The screenplay block to layout
    /// - Returns: Array of lines with proper wrapping and alignment
    public static func layout(block: ScreenplayBlock) -> [Line] {
        guard !block.text.isEmpty else { return [] }
        
        switch block.element {
        case .sceneHeading:
            return layoutSceneHeading(block.text)
        case .action:
            return layoutAction(block.text)
        case .character:
            return layoutCharacter(block.text)
        case .parenthetical:
            return layoutParenthetical(block.text)
        case .dialogue:
            return layoutDialogue(block.text)
        case .transition:
            return layoutTransition(block.text)
        case .shot:
            return layoutShot(block.text)
        case .centered:
            return layoutCentered(block.text)
        case .general:
            return layoutGeneral(block.text)
        case .section:
            return [] // Section headers are structural, not rendered as lines
        case .lyric:
            return layoutLyric(block.text)
        case .pageBreak, .synopsis:
            return [] // These are structural, not rendered as lines
        }
    }
    
    // MARK: - Element-Specific Layout
    
    private static func layoutSceneHeading(_ text: String) -> [Line] {
        // Scene headings wrap at 60 characters
        let wrapped = wrapText(text, maxWidth: PaginationLayout.sceneHeadingWidth)
        return wrapped.map { Line(text: $0, element: .sceneHeading, alignment: .left) }
    }
    
    private static func layoutAction(_ text: String) -> [Line] {
        // Action wraps at 60 characters, preferring sentence boundaries
        let wrapped = wrapText(text, maxWidth: PaginationLayout.actionWidth, preferSentenceBreaks: true)
        return wrapped.map { Line(text: $0, element: .action, alignment: .left) }
    }
    
    private static func layoutCharacter(_ text: String) -> [Line] {
        // Character cues do not wrap
        return [Line(text: text, element: .character, alignment: .left)]
    }
    
    private static func layoutParenthetical(_ text: String) -> [Line] {
        // Parentheticals wrap at 26 characters
        let wrapped = wrapText(text, maxWidth: PaginationLayout.parentheticalWidth)
        return wrapped.map { Line(text: $0, element: .parenthetical, alignment: .left) }
    }
    
    private static func layoutDialogue(_ text: String) -> [Line] {
        // Dialogue wraps at 35 characters
        let wrapped = wrapText(text, maxWidth: PaginationLayout.dialogueWidth)
        return wrapped.map { Line(text: $0, element: .dialogue, alignment: .left) }
    }
    
    private static func layoutTransition(_ text: String) -> [Line] {
        // Transitions are right-aligned, no wrap
        return [Line(text: text, element: .transition, alignment: .right)]
    }
    
    private static func layoutShot(_ text: String) -> [Line] {
        // Shots wrap at 60 characters
        let wrapped = wrapText(text, maxWidth: PaginationLayout.actionWidth)
        return wrapped.map { Line(text: $0, element: .shot, alignment: .left) }
    }
    
    private static func layoutCentered(_ text: String) -> [Line] {
        // Centered text wraps at 60 characters
        let wrapped = wrapText(text, maxWidth: PaginationLayout.actionWidth)
        return wrapped.map { Line(text: $0, element: .centered, alignment: .center) }
    }
    
    private static func layoutGeneral(_ text: String) -> [Line] {
        // General text wraps at 60 characters
        let wrapped = wrapText(text, maxWidth: PaginationLayout.actionWidth)
        return wrapped.map { Line(text: $0, element: .general, alignment: .left) }
    }
    
    private static func layoutLyric(_ text: String) -> [Line] {
        // Lyrics wrap at 60 characters
        let wrapped = wrapText(text, maxWidth: PaginationLayout.actionWidth)
        return wrapped.map { Line(text: $0, element: .lyric, alignment: .left) }
    }
    
    // MARK: - Text Wrapping
    
    /// Wraps text at word boundaries to fit within maxWidth characters.
    /// For action elements, prefers breaking at sentence boundaries when possible.
    private static func wrapText(_ text: String, maxWidth: Int, preferSentenceBreaks: Bool = false) -> [String] {
        guard maxWidth > 0 else { return [text] }
        
        if preferSentenceBreaks {
            return wrapWithSentenceBreaks(text, maxWidth: maxWidth)
        } else {
            return wrapAtWordBoundaries(text, maxWidth: maxWidth)
        }
    }
    
    /// Wraps text at word boundaries (basic wrapping).
    private static func wrapAtWordBoundaries(_ text: String, maxWidth: Int) -> [String] {
        var lines: [String] = []
        var currentLine = ""
        let words = text.split(separator: " ", omittingEmptySubsequences: false)
        
        for word in words {
            let potentialLine: String
            if currentLine.isEmpty {
                potentialLine = String(word)
            } else {
                potentialLine = currentLine + " " + word
            }
            
            if potentialLine.count <= maxWidth {
                currentLine = potentialLine
            } else {
                if !currentLine.isEmpty {
                    lines.append(currentLine)
                }
                currentLine = String(word)
            }
        }
        
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        return lines.isEmpty ? [text] : lines
    }
    
    /// Wraps text preferring sentence boundaries for action elements.
    private static func wrapWithSentenceBreaks(_ text: String, maxWidth: Int) -> [String] {
        var lines: [String] = []
        var currentLine = ""
        
        // Split into sentences (rough approximation)
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        
        for (index, sentence) in sentences.enumerated() {
            let trimmedSentence = sentence.trimmingCharacters(in: .whitespaces)
            if trimmedSentence.isEmpty { continue }
            
            let sentenceWithPunct = trimmedSentence + (index < sentences.count - 1 ? "." : "")
            
            // Try to add the whole sentence
            let potentialLine: String
            if currentLine.isEmpty {
                potentialLine = sentenceWithPunct
            } else {
                potentialLine = currentLine + " " + sentenceWithPunct
            }
            
            if potentialLine.count <= maxWidth {
                currentLine = potentialLine
            } else {
                // Sentence doesn't fit, need to break it
                if !currentLine.isEmpty {
                    lines.append(currentLine)
                    currentLine = sentenceWithPunct
                } else {
                    // Single sentence is too long, fall back to word wrapping
                    let wrapped = wrapAtWordBoundaries(sentenceWithPunct, maxWidth: maxWidth)
                    lines.append(contentsOf: wrapped)
                }
            }
        }
        
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        return lines.isEmpty ? [text] : lines
    }
}
