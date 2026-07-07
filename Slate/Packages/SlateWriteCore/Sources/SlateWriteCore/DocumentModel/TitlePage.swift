import Foundation

/// Fountain title-page key-value metadata (FR-10).
public struct TitlePage: Codable, Sendable, Equatable {
    public var fields: [String: String]
    
    /// Standard title page fields
    public var title: String
    public var authors: String
    public var contact: String
    public var version: String

    public init(
        fields: [String: String] = [:],
        title: String = "",
        authors: String = "",
        contact: String = "",
        version: String = ""
    ) {
        self.fields = fields
        self.title = title
        self.authors = authors
        self.contact = contact
        self.version = version
    }

    public subscript(key: String) -> String? {
        get { fields[key] }
        set {
            if let newValue {
                fields[key] = newValue
            } else {
                fields.removeValue(forKey: key)
            }
        }
    }
    
    /// Legacy author field (singular) for backward compatibility
    public var author: String? {
        get { self["Author"] ?? self["author"] }
        set { self["Author"] = newValue }
    }
}
