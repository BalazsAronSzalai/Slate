import Foundation
import Testing
@testable import SlateWriteCore

@Suite("Fountain parser")
struct FountainParserTests {

    @Test("Parses title page and scene headings")
    func titlePageAndScenes() {
        let source = """
        Title: Test Script
        Author: Máté

        INT. KITCHEN - NIGHT

        A kettle whistles.

        SANDRA
        Tea?

        """
        let (doc, report) = FountainParser.parse(source)
        #expect(doc.titlePage.title == "Test Script")
        #expect(doc.titlePage.author == "Máté")
        #expect(report.warnings.isEmpty)
        #expect(doc.blocks.contains { $0.element == .sceneHeading && $0.text == "INT. KITCHEN - NIGHT" })
        #expect(doc.blocks.contains { $0.element == .character && $0.text == "SANDRA" })
        #expect(doc.blocks.contains { $0.element == .dialogue && $0.text == "Tea?" })
    }

    @Test("Forced Fountain prefixes round-trip")
    func forcedPrefixes() throws {
        let source = """
        .INT. LAB - DAY

        !An explosion of color.

        @ALICE
        Hello.

        > CUT TO:

        """
        let (parsed, _) = FountainParser.parse(source)
        let exported = FountainExporter.export(parsed)
        let (reparsed, _) = FountainParser.parse(exported)

        #expect(parsed.blocks.map(\.element) == reparsed.blocks.map(\.element))
        #expect(parsed.plainTextDump() == reparsed.plainTextDump())
    }

    @Test("Big Fish sample fixture parses without crash")
    func bigFishSample() throws {
        let url = try #require(Bundle.module.url(
            forResource: "big-fish-sample",
            withExtension: "fountain",
            subdirectory: "Fixtures"
        ))
        let source = try String(contentsOf: url, encoding: .utf8)
        let (doc, _) = FountainParser.parse(source)

        #expect(doc.titlePage.title == "Big Fish")
        #expect(doc.scenes.count >= 3)
        #expect(!doc.plainTextDump().isEmpty)
    }

    @Test("Plain text dump is stable after export/import cycle")
    func roundTripPlainText() {
        let source = """
        INT. ROAD - DAY

        A car speeds past.

        DRIVER
        We're late.

        """
        let (doc, _) = FountainParser.parse(source)
        let roundTripped = FountainRoundTrip.exportThenParse(doc)
        #expect(doc.plainTextDump() == roundTripped.plainTextDump())
    }

    @Test("Page breaks and synopses preserved semantically")
    func structuralElements() {
        let source = """
        = A quiet opening.

        INT. HOUSE - DAY

        Action here.

        ===

        EXT. GARDEN - DAY

        More action.

        """
        let (doc, _) = FountainParser.parse(source)
        #expect(doc.blocks.contains { $0.element == .synopsis })
        #expect(doc.blocks.contains { $0.element == .pageBreak })
        let roundTripped = FountainRoundTrip.exportThenParse(doc)
        #expect(doc.blocks.map(\.element) == roundTripped.blocks.map(\.element))
    }
}
