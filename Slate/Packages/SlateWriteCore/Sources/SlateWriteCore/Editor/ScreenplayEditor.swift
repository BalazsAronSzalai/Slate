import Foundation

/// Editor state and operations for screenplay editing.
/// Handles element cycling, auto-detection, and document mutations.
public actor ScreenplayEditor {
    public private(set) var document: ScreenplayDocument
    private var versionSnapshots: [VersionSnapshot] = []
    private let maxSnapshots = 10
    
    public init(document: ScreenplayDocument = ScreenplayDocument()) {
        self.document = document
    }
    
    /// Cycling direction for Tab (forward) and Enter (backward).
    public enum CycleDirection: Sendable {
        case forward  // Tab key
        case backward // Enter key
    }
    
    /// Cycles the element type at the specified block index.
    /// - Parameters:
    ///   - index: The block index to cycle
    ///   - direction: Forward (Tab) or backward (Enter)
    public func cycleElement(at index: Int, direction: CycleDirection) {
        guard index >= 0 && index < document.blocks.count else { return }
        
        let currentElement = document.blocks[index].element
        let newElement = nextElement(from: currentElement, direction: direction)
        
        document.blocks[index] = ScreenplayBlock(
            element: newElement,
            text: document.blocks[index].text
        )
        document.updatedAt = .now
    }
    
    /// Inserts a new block at the specified index with auto-detected element type.
    /// - Parameters:
    ///   - text: The text content for the new block
    ///   - index: The index where to insert the block
    public func insertBlock(text: String, at index: Int) {
        guard index >= 0 && index <= document.blocks.count else { return }
        
        let detectedElement = ScreenplayElement.detect(from: text)
        let newBlock = ScreenplayBlock(element: detectedElement, text: text)
        
        document.blocks.insert(newBlock, at: index)
        document.updatedAt = .now
        createAutosave()
    }
    
    /// Updates the text of a block at the specified index with auto-detection.
    /// - Parameters:
    ///   - index: The block index to update
    ///   - text: The new text content
    public func updateBlock(at index: Int, text: String) {
        guard index >= 0 && index < document.blocks.count else { return }
        
        let detectedElement = ScreenplayElement.detect(from: text)
        let currentBlock = document.blocks[index]
        
        // If auto-detection fails (returns action), preserve original element
        let newElement = (detectedElement == .action && currentBlock.element != .action) 
            ? currentBlock.element 
            : detectedElement
        
        document.blocks[index] = ScreenplayBlock(element: newElement, text: text)
        document.updatedAt = .now
        createAutosave()
    }
    
    // MARK: - Test Helpers
    
    /// Returns the block count (for testing)
    public func blockCount() -> Int {
        document.blocks.count
    }
    
    /// Returns the element type at the specified index (for testing)
    public func element(at index: Int) -> ScreenplayElement? {
        guard index >= 0 && index < document.blocks.count else { return nil }
        return document.blocks[index].element
    }
    
    /// Returns the text at the specified index (for testing)
    public func text(at index: Int) -> String? {
        guard index >= 0 && index < document.blocks.count else { return nil }
        return document.blocks[index].text
    }
    
    /// Returns the document's updated timestamp (for testing)
    public func documentUpdatedAt() -> Date {
        document.updatedAt
    }
    
    // MARK: - SmartType
    
    /// Returns all unique character names from the document, in insertion order.
    public func characterNames() -> [String] {
        var seen = Set<String>()
        var names: [String] = []
        
        for block in document.blocks {
            if block.element == .character {
                let name = block.text.trimmingCharacters(in: .whitespaces)
                if !seen.contains(name) && !name.isEmpty {
                    seen.insert(name)
                    names.append(name)
                }
            }
        }
        
        return names
    }
    
    /// Returns character names that match the given prefix (case-insensitive).
    /// - Parameter prefix: The prefix to match
    /// - Returns: Filtered character names
    public func characterNames(matching prefix: String) -> [String] {
        let allNames = characterNames()
        let lowerPrefix = prefix.lowercased()
        
        if lowerPrefix.isEmpty {
            return allNames
        }
        
        return allNames.filter { $0.lowercased().hasPrefix(lowerPrefix) }
    }
    
    /// Returns all unique locations from scene headings, in insertion order.
    /// Extracts the location name from scene headings (e.g., "INT. COFFEE SHOP - DAY" → "COFFEE SHOP")
    public func locations() -> [String] {
        var seen = Set<String>()
        var locations: [String] = []
        
        for block in document.blocks {
            if block.element == .sceneHeading {
                if let location = extractLocation(from: block.text) {
                    if !seen.contains(location) && !location.isEmpty {
                        seen.insert(location)
                        locations.append(location)
                    }
                }
            }
        }
        
        return locations
    }
    
    /// Returns locations that match the given prefix (case-insensitive).
    /// - Parameter prefix: The prefix to match
    /// - Returns: Filtered locations
    public func locations(matching prefix: String) -> [String] {
        let allLocations = locations()
        let lowerPrefix = prefix.lowercased()
        
        if lowerPrefix.isEmpty {
            return allLocations
        }
        
        return allLocations.filter { $0.lowercased().hasPrefix(lowerPrefix) }
    }
    
    // MARK: - Private Helpers
    
    /// Extracts the location name from a scene heading.
    /// - Parameter sceneHeading: The scene heading text (e.g., "INT. COFFEE SHOP - DAY")
    /// - Returns: The location name (e.g., "COFFEE SHOP")
    private func extractLocation(from sceneHeading: String) -> String? {
        let trimmed = sceneHeading.trimmingCharacters(in: .whitespaces)
        
        // Remove scene heading prefix (INT., EXT., EST., etc.)
        let prefixes = ["INT.", "EXT.", "EST.", "INT./EXT.", "INT./EST."]
        var locationText = trimmed
        
        for prefix in prefixes {
            if locationText.hasPrefix(prefix) {
                locationText = String(locationText.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
                break
            }
        }
        
        // Remove time suffix (DAY, NIGHT, MORNING, etc.)
        let timeSuffixes = [" - DAY", " - NIGHT", " - MORNING", " - AFTERNOON", " - EVENING", " - CONTINUOUS", " - LATER", " - MOMENTS LATER"]
        for suffix in timeSuffixes {
            if locationText.hasSuffix(suffix) {
                locationText = String(locationText.dropLast(suffix.count)).trimmingCharacters(in: .whitespaces)
                break
            }
        }
        
        return locationText.isEmpty ? nil : locationText
    }
    
    /// Extracts the time of day from a scene heading.
    /// - Parameter sceneHeading: The scene heading text (e.g., "INT. COFFEE SHOP - DAY")
    /// - Returns: The time of day (e.g., "DAY")
    private func extractTimeOfDay(from sceneHeading: String) -> String? {
        let trimmed = sceneHeading.trimmingCharacters(in: .whitespaces)
        
        let timeSuffixes = [" - DAY", " - NIGHT", " - MORNING", " - AFTERNOON", " - EVENING", " - CONTINUOUS", " - LATER", " - MOMENTS LATER"]
        for suffix in timeSuffixes {
            if trimmed.hasSuffix(suffix) {
                return String(suffix.dropFirst(3)) // Remove " - "
            }
        }
        
        return nil
    }
    
    // MARK: - Scene Navigator
    
    /// Returns all scenes in the document, in order.
    public func scenes() -> [Scene] {
        var scenes: [Scene] = []
        
        for (index, block) in document.blocks.enumerated() {
            if block.element == .sceneHeading {
                let location = extractLocation(from: block.text) ?? ""
                let timeOfDay = extractTimeOfDay(from: block.text) ?? ""
                let scene = Scene(
                    heading: block.text,
                    location: location,
                    timeOfDay: timeOfDay,
                    blockIndex: index
                )
                scenes.append(scene)
            }
        }
        
        return scenes
    }
    
    /// Returns the scene index for a given block index.
    /// - Parameter blockIndex: The block index to find the scene for
    /// - Returns: The scene index, or nil if the block is not in a scene
    public func sceneIndex(forBlock blockIndex: Int) -> Int? {
        let allScenes = scenes()
        
        // Find the last scene that starts before or at this block
        for i in stride(from: allScenes.count - 1, through: 0, by: -1) {
            if allScenes[i].blockIndex <= blockIndex {
                return i
            }
        }
        
        return nil
    }
    
    /// Returns scenes at a specific location.
    /// - Parameter location: The location name to filter by
    /// - Returns: Filtered scenes
    public func scenes(atLocation location: String) -> [Scene] {
        let allScenes = scenes()
        return allScenes.filter { $0.location == location }
    }
    
    /// Returns scenes at a specific time of day.
    /// - Parameter time: The time of day to filter by
    /// - Returns: Filtered scenes
    public func scenes(atTime time: String) -> [Scene] {
        let allScenes = scenes()
        return allScenes.filter { $0.timeOfDay == time }
    }
    
    // MARK: - Title Page Editor
    
    /// Title page field identifiers
    public enum TitlePageField {
        case title
        case authors
        case contact
        case version
    }
    
    /// Updates a title page field.
    /// - Parameters:
    ///   - field: The field to update
    ///   - value: The new value
    public func updateTitlePageField(_ field: TitlePageField, value: String) {
        switch field {
        case .title:
            document.titlePage.title = value
        case .authors:
            document.titlePage.authors = value
        case .contact:
            document.titlePage.contact = value
        case .version:
            document.titlePage.version = value
        }
        document.updatedAt = .now
    }
    
    /// Returns the value of a title page field (for testing).
    /// - Parameter field: The field to retrieve
    /// - Returns: The field value
    public func titlePageField(_ field: TitlePageField) -> String {
        switch field {
        case .title:
            return document.titlePage.title
        case .authors:
            return document.titlePage.authors
        case .contact:
            return document.titlePage.contact
        case .version:
            return document.titlePage.version
        }
    }
    
    // MARK: - Autosave & Version Snapshots
    
    /// Creates a version snapshot of the current document state.
    /// - Parameter name: The snapshot name (e.g., "Initial Draft" or "Autosave")
    public func createSnapshot(name: String) {
        let snapshot = VersionSnapshot(name: name, document: document)
        versionSnapshots.append(snapshot)
        
        // Enforce maximum snapshot count
        if versionSnapshots.count > maxSnapshots {
            versionSnapshots.removeFirst()
        }
    }
    
    /// Returns all snapshots, in chronological order.
    /// - Returns: Array of version snapshots
    public func snapshots() -> [VersionSnapshot] {
        versionSnapshots
    }
    
    /// Restores the document to a previous snapshot.
    /// - Parameter index: The snapshot index to restore
    public func restoreSnapshot(at index: Int) {
        guard index >= 0 && index < versionSnapshots.count else { return }
        document = versionSnapshots[index].document
        document.updatedAt = .now
    }
    
    /// Deletes a snapshot at the specified index.
    /// - Parameter index: The snapshot index to delete
    public func deleteSnapshot(at index: Int) {
        guard index >= 0 && index < versionSnapshots.count else { return }
        versionSnapshots.remove(at: index)
    }
    
    /// Creates an automatic autosave snapshot.
    private func createAutosave() {
        let timestamp = ISO8601DateFormatter().string(from: .now)
        let name = "Autosave - \(timestamp)"
        createSnapshot(name: name)
    }
    
    private func nextElement(from element: ScreenplayElement, direction: CycleDirection) -> ScreenplayElement {
        // Standard cycling order for Tab (forward):
        // sceneHeading -> action -> character -> dialogue -> parenthetical -> dialogue -> transition -> sceneHeading
        let forwardCycle: [ScreenplayElement] = [
            .sceneHeading, .action, .character, .dialogue, .parenthetical, .dialogue, .transition
        ]
        
        // For Enter (backward), reverse the cycle
        let backwardCycle: [ScreenplayElement] = forwardCycle.reversed()
        
        let cycle = direction == .forward ? forwardCycle : backwardCycle
        
        guard let currentIndex = cycle.firstIndex(of: element) else {
            // For elements not in the standard cycle (shot, general, etc.), default to sceneHeading
            return .sceneHeading
        }
        
        let nextIndex = (currentIndex + 1) % cycle.count
        return cycle[nextIndex]
    }
}
