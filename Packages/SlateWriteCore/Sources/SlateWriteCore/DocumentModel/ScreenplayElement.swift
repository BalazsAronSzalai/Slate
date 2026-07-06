import Foundation

/// The type of a screenplay element, following industry-standard formatting categories.
///
/// Raw values are stable API (persisted) — never rename, only add.
public enum ElementType: String, Codable, Sendable, CaseIterable {
    case sceneHeading
    case action
    case character
    case dialogue
    case parenthetical
    case transition
    case shot
    case lyrics
    case section
    case synopsis
    case pageBreak
}

/// A production revision color, in standard industry order.
public enum RevisionColor: String, Codable, Sendable, CaseIterable {
    case white
    case blue
    case pink
    case yellow
    case green
    case goldenrod
    case buff
    case salmon
    case cherry
    case doubleWhite
}

/// Revision state of an element within a locked script.
public enum RevisionState: Codable, Sendable, Equatable {
    case none
    case revised(color: RevisionColor)
}

/// A single block of screenplay content (one scene heading, one action paragraph,
/// one character cue, etc.).
public struct ScreenplayElement: Identifiable, Codable, Sendable, Equatable {
    public var id: UUID
    public var type: ElementType
    public var text: String
    public var isDualDialogue: Bool
    public var isCentered: Bool
    public var sceneNumber: String?
    public var sectionDepth: Int
    public var notes: [String]
    public var revision: RevisionState

    public init(
        id: UUID = UUID(),
        type: ElementType,
        text: String,
        isDualDialogue: Bool = false,
        isCentered: Bool = false,
        sceneNumber: String? = nil,
        sectionDepth: Int = 0,
        notes: [String] = [],
        revision: RevisionState = .none
    ) {
        self.id = id
        self.type = type
        self.text = text
        self.isDualDialogue = isDualDialogue
        self.isCentered = isCentered
        self.sceneNumber = sceneNumber
        self.sectionDepth = sectionDepth
        self.notes = notes
        self.revision = revision
    }

    /// Whether two elements carry the same content, ignoring identity.
    public func contentEquals(_ other: ScreenplayElement) -> Bool {
        type == other.type
            && text == other.text
            && isDualDialogue == other.isDualDialogue
            && isCentered == other.isCentered
            && sceneNumber == other.sceneNumber
            && sectionDepth == other.sectionDepth
            && notes == other.notes
            && revision == other.revision
    }
}
