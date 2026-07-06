import Testing
@testable import SlateWriteCore

@Suite("ScreenplayElement")
struct ScreenplayElementTests {
    @Test func newElement_hasDefaults() {
        let element = ScreenplayElement(type: .action, text: "He runs.")
        #expect(element.type == .action)
        #expect(element.text == "He runs.")
        #expect(element.isDualDialogue == false)
        #expect(element.isCentered == false)
        #expect(element.sceneNumber == nil)
        #expect(element.revision == .none)
    }

    @Test func elementsWithSameContent_differentIdentity_areNotEqualByID() {
        let a = ScreenplayElement(type: .action, text: "Same")
        let b = ScreenplayElement(type: .action, text: "Same")
        #expect(a.id != b.id)
        #expect(a.contentEquals(b))
    }

    @Test(arguments: ElementType.allCases)
    func allElementTypes_roundTripRawValue(type: ElementType) {
        #expect(ElementType(rawValue: type.rawValue) == type)
    }
}

@Suite("ScreenplayDocument")
struct ScreenplayDocumentTests {
    @Test func emptyDocument_hasNoElementsAndEmptyTitlePage() {
        let doc = ScreenplayDocument()
        #expect(doc.elements.isEmpty)
        #expect(doc.titlePage.isEmpty)
    }

    @Test func titlePage_preservesEntryOrderAndValues() {
        var doc = ScreenplayDocument()
        doc.titlePage = [
            TitlePageEntry(key: "Title", value: "Big Fish"),
            TitlePageEntry(key: "Credit", value: "written by"),
            TitlePageEntry(key: "Author", value: "John August"),
        ]
        #expect(doc.titlePage.map(\.key) == ["Title", "Credit", "Author"])
        #expect(doc.titlePage[0].value == "Big Fish")
    }

    @Test func sceneHeadings_areExtractedInOrder() {
        var doc = ScreenplayDocument()
        doc.elements = [
            ScreenplayElement(type: .sceneHeading, text: "INT. HOUSE - DAY"),
            ScreenplayElement(type: .action, text: "Something happens."),
            ScreenplayElement(type: .sceneHeading, text: "EXT. RIVER - NIGHT"),
        ]
        #expect(doc.sceneHeadings.map(\.text) == ["INT. HOUSE - DAY", "EXT. RIVER - NIGHT"])
    }

    @Test func revisionMark_persistsOnElement() {
        var element = ScreenplayElement(type: .dialogue, text: "New line.")
        element.revision = .revised(color: .blue)
        #expect(element.revision == .revised(color: .blue))
    }
}
