import XCTest
@testable import SlateWriteCore

final class TitlePageEditorTests: XCTestCase {
    
    // MARK: - Title Page Field Updates
    
    func testUpdatesTitle() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.updateTitlePageField(.title, value: "My Screenplay")
        
        let title = await editor.titlePageField(.title)
        XCTAssertEqual(title, "My Screenplay")
    }
    
    func testUpdatesAuthors() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.updateTitlePageField(.authors, value: "John Doe")
        
        let authors = await editor.titlePageField(.authors)
        XCTAssertEqual(authors, "John Doe")
    }
    
    func testUpdatesContact() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.updateTitlePageField(.contact, value: "john@example.com")
        
        let contact = await editor.titlePageField(.contact)
        XCTAssertEqual(contact, "john@example.com")
    }
    
    func testUpdatesVersion() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.updateTitlePageField(.version, value: "First Draft")
        
        let version = await editor.titlePageField(.version)
        XCTAssertEqual(version, "First Draft")
    }
    
    // MARK: - Document Timestamp Updates
    
    func testTitlePageUpdateUpdatesDocumentTimestamp() async {
        var document = ScreenplayDocument()
        let originalUpdatedAt = document.updatedAt
        let editor = ScreenplayEditor(document: document)
        
        try? await Task.sleep(nanoseconds: 10_000_000)
        
        await editor.updateTitlePageField(.title, value: "New Title")
        
        let updatedAt = await editor.documentUpdatedAt()
        XCTAssertGreaterThan(updatedAt, originalUpdatedAt)
    }
    
    // MARK: - Field Validation
    
    func testAllowsEmptyTitle() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.updateTitlePageField(.title, value: "")
        
        let title = await editor.titlePageField(.title)
        XCTAssertEqual(title, "")
    }
    
    func testAllowsEmptyAuthors() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.updateTitlePageField(.authors, value: "")
        
        let authors = await editor.titlePageField(.authors)
        XCTAssertEqual(authors, "")
    }
    
    func testPreservesWhitespaceInFields() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        await editor.updateTitlePageField(.title, value: "  My Title  ")
        
        let title = await editor.titlePageField(.title)
        XCTAssertEqual(title, "  My Title  ")
    }
    
    // MARK: - Multi-line Fields
    
    func testHandlesMultiLineAuthors() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        let multiLineAuthors = "John Doe\nJane Smith"
        await editor.updateTitlePageField(.authors, value: multiLineAuthors)
        
        let authors = await editor.titlePageField(.authors)
        XCTAssertEqual(authors, multiLineAuthors)
    }
    
    func testHandlesMultiLineContact() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        
        let multiLineContact = "email@example.com\n555-1234"
        await editor.updateTitlePageField(.contact, value: multiLineContact)
        
        let contact = await editor.titlePageField(.contact)
        XCTAssertEqual(contact, multiLineContact)
    }
}
