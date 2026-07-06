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
}
