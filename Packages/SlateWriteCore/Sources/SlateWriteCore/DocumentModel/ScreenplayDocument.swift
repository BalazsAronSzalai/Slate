import Foundation

/// One key–value entry on a screenplay title page. Order is significant.
public struct TitlePageEntry: Codable, Sendable, Equatable {
    public var key: String
    public var value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

/// The in-memory representation of a screenplay: an ordered title page
/// plus an ordered list of elements.
public struct ScreenplayDocument: Codable, Sendable, Equatable {
    public var titlePage: [TitlePageEntry]
    public var elements: [ScreenplayElement]

    public init(titlePage: [TitlePageEntry] = [], elements: [ScreenplayElement] = []) {
        self.titlePage = titlePage
        self.elements = elements
    }

    /// All scene heading elements, in document order.
    public var sceneHeadings: [ScreenplayElement] {
        elements.filter { $0.type == .sceneHeading }
    }
}
