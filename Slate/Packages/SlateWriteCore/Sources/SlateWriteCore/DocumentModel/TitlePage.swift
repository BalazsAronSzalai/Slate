import Foundation

/// Fountain title-page key-value metadata (FR-10).
public struct TitlePage: Codable, Sendable, Equatable {
    public var fields: [String: String]

    public init(fields: [String: String] = [:]) {
        self.fields = fields
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

    public var title: String? {
        get { self["Title"] ?? self["title"] }
        set { self["Title"] = newValue }
    }

    public var author: String? {
        get { self["Author"] ?? self["author"] }
        set { self["Author"] = newValue }
    }
}
