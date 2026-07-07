import Foundation

/// Industry screenplay element types (FR-01).
public enum ScreenplayElement: String, Codable, Sendable, CaseIterable {
    case sceneHeading
    case action
    case character
    case dialogue
    case parenthetical
    case transition
    case shot
    case general
    case section
    case synopsis
    case pageBreak
    case centered
    case lyric
}

extension ScreenplayElement {
    /// Default element after pressing Return from this element (Tab/Enter cycling baseline).
    public var nextOnReturn: ScreenplayElement {
        switch self {
        case .sceneHeading: .action
        case .action: .action
        case .character: .dialogue
        case .parenthetical: .dialogue
        case .dialogue: .character
        case .transition: .action
        case .shot: .action
        case .general: .general
        case .section, .synopsis: .action
        case .pageBreak: .action
        case .centered: .action
        case .lyric: .lyric
        }
    }
    
    /// Auto-detects the element type from raw text input.
    /// - Parameter text: The text to analyze
    /// - Returns: The detected element type, defaults to `.action`
    public static func detect(from text: String) -> ScreenplayElement {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        
        // Empty string defaults to action
        if trimmed.isEmpty {
            return .action
        }
        
        // Forced page break
        if trimmed.contains("===") {
            return .pageBreak
        }
        
        // Centered text
        if trimmed.hasPrefix(">") {
            return .centered
        }
        
        // Section headers (#, ##) and synopsis (###)
        if trimmed.hasPrefix("###") {
            return .synopsis
        }
        if trimmed.hasPrefix("##") || trimmed.hasPrefix("#") {
            return .section
        }
        
        // Scene headings (INT., EXT., EST., INT./EXT., INT./EST.) - must be at start
        let sceneHeadingPrefixes = ["INT.", "EXT.", "EST.", "INT./EXT.", "INT./EST."]
        for prefix in sceneHeadingPrefixes {
            if trimmed.hasPrefix(prefix) {
                return .sceneHeading
            }
        }
        
        // Transitions (ALL CAPS with colon)
        if trimmed.hasSuffix(":") && trimmed == trimmed.uppercased() {
            return .transition
        }
        
        // Parentheticals
        if trimmed.hasPrefix("(") && trimmed.hasSuffix(")") {
            return .parenthetical
        }
        
        // Character cues (ALL CAPS, no colon, not a transition)
        // Must be entirely uppercase and not contain lowercase letters
        let isAllUppercase = trimmed == trimmed.uppercased() && trimmed != trimmed.lowercased()
        if isAllUppercase && !trimmed.hasSuffix(":") {
            return .character
        }
        
        // Default to action
        return .action
    }
}
