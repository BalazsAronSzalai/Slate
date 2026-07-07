import XCTest
@testable import SlateWriteCore

final class SmartTypeTests: XCTestCase {
    
    // MARK: - Character Name Extraction
    
    func testExtractsCharacterNamesFromDocument() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .character, text: "JOHN"))
        document.appendBlock(ScreenplayBlock(element: .dialogue, text: "Hello."))
        document.appendBlock(ScreenplayBlock(element: .character, text: "JANE"))
        document.appendBlock(ScreenplayBlock(element: .dialogue, text: "Hi there."))
        
        let editor = ScreenplayEditor(document: document)
        let names = await editor.characterNames()
        
        XCTAssertEqual(names.count, 2)
        XCTAssertTrue(names.contains("JOHN"))
        XCTAssertTrue(names.contains("JANE"))
    }
    
    func testExtractsUniqueCharacterNames() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .character, text: "JOHN"))
        document.appendBlock(ScreenplayBlock(element: .dialogue, text: "Hello."))
        document.appendBlock(ScreenplayBlock(element: .character, text: "JOHN"))
        document.appendBlock(ScreenplayBlock(element: .dialogue, text: "Again."))
        
        let editor = ScreenplayEditor(document: document)
        let names = await editor.characterNames()
        
        XCTAssertEqual(names.count, 1)
        XCTAssertEqual(names.first, "JOHN")
    }
    
    func testIgnoresNonCharacterElements() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. LOCATION"))
        document.appendBlock(ScreenplayBlock(element: .action, text: "John walks in."))
        document.appendBlock(ScreenplayBlock(element: .character, text: "JOHN"))
        document.appendBlock(ScreenplayBlock(element: .transition, text: "CUT TO:"))
        
        let editor = ScreenplayEditor(document: document)
        let names = await editor.characterNames()
        
        XCTAssertEqual(names.count, 1)
        XCTAssertEqual(names.first, "JOHN")
    }
    
    func testHandlesEmptyDocument() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        let names = await editor.characterNames()
        
        XCTAssertEqual(names.count, 0)
    }
    
    func testPreservesInsertionOrder() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .character, text: "CHARLIE"))
        document.appendBlock(ScreenplayBlock(element: .character, text: "BOB"))
        document.appendBlock(ScreenplayBlock(element: .character, text: "ALICE"))
        document.appendBlock(ScreenplayBlock(element: .character, text: "BOB")) // duplicate
        
        let editor = ScreenplayEditor(document: document)
        let names = await editor.characterNames()
        
        XCTAssertEqual(names, ["CHARLIE", "BOB", "ALICE"])
    }
    
    // MARK: - Character Name Filtering
    
    func testFiltersCharacterNamesByPrefix() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .character, text: "JOHN"))
        document.appendBlock(ScreenplayBlock(element: .character, text: "JANE"))
        document.appendBlock(ScreenplayBlock(element: .character, text: "BOB"))
        
        let editor = ScreenplayEditor(document: document)
        let filtered = await editor.characterNames(matching: "J")
        
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.contains("JOHN"))
        XCTAssertTrue(filtered.contains("JANE"))
        XCTAssertFalse(filtered.contains("BOB"))
    }
    
    func testFiltersCaseInsensitively() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .character, text: "JOHN"))
        document.appendBlock(ScreenplayBlock(element: .character, text: "JANE"))
        
        let editor = ScreenplayEditor(document: document)
        let filtered = await editor.characterNames(matching: "j")
        
        XCTAssertEqual(filtered.count, 2)
    }
    
    func testFiltersWithEmptyPrefixReturnsAll() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .character, text: "JOHN"))
        document.appendBlock(ScreenplayBlock(element: .character, text: "JANE"))
        
        let editor = ScreenplayEditor(document: document)
        let filtered = await editor.characterNames(matching: "")
        
        XCTAssertEqual(filtered.count, 2)
    }
    
    // MARK: - Location Extraction
    
    func testExtractsLocationsFromSceneHeadings() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. COFFEE SHOP - DAY"))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "EXT. PARKING LOT - NIGHT"))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. HOUSE - MORNING"))
        
        let editor = ScreenplayEditor(document: document)
        let locations = await editor.locations()
        
        XCTAssertEqual(locations.count, 3)
        XCTAssertTrue(locations.contains("COFFEE SHOP"))
        XCTAssertTrue(locations.contains("PARKING LOT"))
        XCTAssertTrue(locations.contains("HOUSE"))
    }
    
    func testExtractsUniqueLocations() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. COFFEE SHOP - DAY"))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. COFFEE SHOP - NIGHT"))
        
        let editor = ScreenplayEditor(document: document)
        let locations = await editor.locations()
        
        XCTAssertEqual(locations.count, 1)
        XCTAssertEqual(locations.first, "COFFEE SHOP")
    }
    
    func testHandlesSceneHeadingWithTime() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. KITCHEN - DAY"))
        
        let editor = ScreenplayEditor(document: document)
        let locations = await editor.locations()
        
        XCTAssertEqual(locations.count, 1)
        XCTAssertEqual(locations.first, "KITCHEN")
    }
    
    func testHandlesSceneHeadingWithHyphenatedLocation() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. DINING ROOM - KITCHEN - DAY"))
        
        let editor = ScreenplayEditor(document: document)
        let locations = await editor.locations()
        
        XCTAssertEqual(locations.count, 1)
        XCTAssertEqual(locations.first, "DINING ROOM - KITCHEN")
    }
    
    func testFiltersLocationsByPrefix() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. COFFEE SHOP - DAY"))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. CAFE - NIGHT"))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. HOUSE - DAY"))
        
        let editor = ScreenplayEditor(document: document)
        let filtered = await editor.locations(matching: "C")
        
        XCTAssertEqual(filtered.count, 2)
        XCTAssertTrue(filtered.contains("COFFEE SHOP"))
        XCTAssertTrue(filtered.contains("CAFE"))
        XCTAssertFalse(filtered.contains("HOUSE"))
    }
}
