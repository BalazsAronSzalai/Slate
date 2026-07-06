//
//  Document.swift
//  Slate
//
//  Created by Szalai Balázs Áron on 2026. 07. 06..
//


import Foundation
import SwiftData

// CloudKit constraints: optionals/defaults only. Zone: ProjectZone.
// Linked mode: bookmark + metadata only — never the file itself (§4.2.2).
// #Index on categoryRaw (§4.4.5).
@Model
public final class Document {
    public var id: UUID = UUID()
    public var title: String = ""
    public var categoryRaw: String = DocumentCategory.other.rawValue
    public var storageModeRaw: String = DocumentStorageMode.asset.rawValue
    @Attribute(.externalStorage) public var fileAsset: Data?
    public var bookmarkData: Data?
    public var linkedVolumeName: String?
    public var linkedFileSize: Int64 = 0
    public var lastVerifiedAt: Date?
    public var partialChecksum: String?        // first 1 MB, staleness detection
    public var versionLabel: String = ""
    public var statusRaw: String = DocumentStatus.draft.rawValue
    public var notes: String = ""

    public var project: Project?

    public var category: DocumentCategory {
        get { DocumentCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
    public var storageMode: DocumentStorageMode {
        get { DocumentStorageMode(rawValue: storageModeRaw) ?? .asset }
        set { storageModeRaw = newValue.rawValue }
    }
    public var status: DocumentStatus {
        get { DocumentStatus(rawValue: statusRaw) ?? .draft }
        set { statusRaw = newValue.rawValue }
    }

    public init(title: String = "", category: DocumentCategory = .other) {
        self.title = title
        self.categoryRaw = category.rawValue
    }
}