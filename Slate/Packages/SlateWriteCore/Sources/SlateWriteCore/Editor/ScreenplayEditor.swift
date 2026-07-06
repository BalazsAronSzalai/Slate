import Foundation

/// Editor state and operations for screenplay editing.
/// Handles element cycling, auto-detection, and document mutations.
public actor ScreenplayEditor {
    private(set) var document: ScreenplayDocument
    
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
    
    // MARK: - Private Helpers
    
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
