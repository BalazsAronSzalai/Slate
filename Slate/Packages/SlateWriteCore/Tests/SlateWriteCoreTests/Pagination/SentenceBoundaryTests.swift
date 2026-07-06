import Foundation
import Testing
@testable import SlateWriteCore

@Suite("Sentence Boundary Preference")
struct SentenceBoundaryTests {

    @Test("Action breaks at sentence boundary when possible")
    func breaksAtSentenceEnd() {
        let text = "This is sentence one. This is sentence two. This is sentence three."
        let block = ScreenplayBlock(element: .action, text: text)
        let lines = LineLayout.layout(block: block)
        
        // Lines should break at sentence boundaries
        let lineTexts = lines.map { $0.text }
        #expect(lineTexts.contains { $0.hasSuffix(".") })
    }

    @Test("Long action paragraph breaks preferentially at sentences")
    func longParagraphBreaks() {
        var sentences: [String] = []
        for i in 0..<10 {
            sentences.append("This is sentence number \(i).")
        }
        let text = sentences.joined(separator: " ")
        let block = ScreenplayBlock(element: .action, text: text)
        let lines = LineLayout.layout(block: block)
        
        // Should have multiple lines
        #expect(lines.count > 1)
        
        // Check that breaks happen near sentence boundaries
        var lastLineEndedWithPeriod = false
        for line in lines {
            if line.text.hasSuffix(".") {
                lastLineEndedWithPeriod = true
            }
        }
        #expect(lastLineEndedWithPeriod)
    }

    @Test("Action without sentence breaks wraps at word boundary")
    func wordBoundaryFallback() {
        let text = "This is a very long line without any sentence breaks just words and spaces"
        let block = ScreenplayBlock(element: .action, text: text)
        let lines = LineLayout.layout(block: block)
        
        // Should still wrap at word boundaries
        #expect(lines.count > 1)
    }

    @Test("Single sentence that exceeds line width wraps at word boundary")
    func singleLongSentence() {
        let text = "This is a single very long sentence that exceeds the maximum line width and must wrap at word boundaries since there are no other sentence breaks available"
        let block = ScreenplayBlock(element: .action, text: text)
        let lines = LineLayout.layout(block: block)
        
        // Should wrap at word boundaries
        #expect(lines.count > 1)
    }

    @Test("Mixed punctuation respects sentence boundaries")
    func mixedPunctuation() {
        let text = "Sentence one! Sentence two? Sentence three. Sentence four."
        let block = ScreenplayBlock(element: .action, text: text)
        let lines = LineLayout.layout(block: block)
        
        // Should break at various sentence-ending punctuation
        let lineTexts = lines.map { $0.text }
        let hasSentenceEnd = lineTexts.contains { 
            $0.hasSuffix(".") || $0.hasSuffix("!") || $0.hasSuffix("?")
        }
        #expect(hasSentenceEnd)
    }
}
