import Foundation

/// A single typed block in a screenplay document.
public struct ScreenplayBlock: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public var element: ScreenplayElement
    public var text: String
    /// Inline Fountain notes attached to this block (`[[note]]`).
    public var inlineNotes: [String]
    /// Dual-dialogue column (nil = single column, 0/1 = left/right).
    public var dualDialogueColumn: Int?
    /// Scene number when locked/exported (`#8#` in Fountain).
    public var sceneNumber: String?

    public init(
        id: UUID = UUID(),
        element: ScreenplayElement,
        text: String,
        inlineNotes: [String] = [],
        dualDialogueColumn: Int? = nil,
        sceneNumber: String? = nil
    ) {
        self.id = id
        self.element = element
        self.text = text
        self.inlineNotes = inlineNotes
        self.dualDialogueColumn = dualDialogueColumn
        self.sceneNumber = sceneNumber
    }
}
