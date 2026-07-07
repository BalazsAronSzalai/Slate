import XCTest
@testable import SlateWriteCore

final class SceneNavigatorTests: XCTestCase {
    
    // MARK: - Scene Extraction
    
    func testExtractsScenesFromDocument() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. COFFEE SHOP - DAY"))
        document.appendBlock(ScreenplayBlock(element: .action, text: "John walks in."))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "EXT. PARKING LOT - NIGHT"))
        document.appendBlock(ScreenplayBlock(element: .action, text: "Jane exits."))
        
        let editor = ScreenplayEditor(document: document)
        let scenes = await editor.scenes()
        
        XCTAssertEqual(scenes.count, 2)
        XCTAssertEqual(scenes[0].heading, "INT. COFFEE SHOP - DAY")
        XCTAssertEqual(scenes[1].heading, "EXT. PARKING LOT - NIGHT")
    }
    
    func testSceneIncludesBlockIndex() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. FIRST"))
        document.appendBlock(ScreenplayBlock(element: .action, text: "Action"))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. SECOND"))
        
        let editor = ScreenplayEditor(document: document)
        let scenes = await editor.scenes()
        
        XCTAssertEqual(scenes[0].blockIndex, 0)
        XCTAssertEqual(scenes[1].blockIndex, 2)
    }
    
    func testSceneIncludesLocation() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. COFFEE SHOP - DAY"))
        
        let editor = ScreenplayEditor(document: document)
        let scenes = await editor.scenes()
        
        XCTAssertEqual(scenes[0].location, "COFFEE SHOP")
    }
    
    func testSceneIncludesTimeOfDay() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. HOUSE - NIGHT"))
        
        let editor = ScreenplayEditor(document: document)
        let scenes = await editor.scenes()
        
        XCTAssertEqual(scenes[0].timeOfDay, "NIGHT")
    }
    
    func testHandlesEmptyDocument() async {
        let document = ScreenplayDocument()
        let editor = ScreenplayEditor(document: document)
        let scenes = await editor.scenes()
        
        XCTAssertEqual(scenes.count, 0)
    }
    
    func testHandlesDocumentWithNoScenes() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .action, text: "Some action."))
        document.appendBlock(ScreenplayBlock(element: .character, text: "JOHN"))
        
        let editor = ScreenplayEditor(document: document)
        let scenes = await editor.scenes()
        
        XCTAssertEqual(scenes.count, 0)
    }
    
    // MARK: - Scene Navigation
    
    func testFindsSceneIndexForBlock() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. FIRST"))
        document.appendBlock(ScreenplayBlock(element: .action, text: "Action"))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. SECOND"))
        
        let editor = ScreenplayEditor(document: document)
        let sceneIndex = await editor.sceneIndex(forBlock: 2)
        
        XCTAssertEqual(sceneIndex, 1)
    }
    
    func testReturnsNilForBlockNotInScene() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .action, text: "Action"))
        
        let editor = ScreenplayEditor(document: document)
        let sceneIndex = await editor.sceneIndex(forBlock: 0)
        
        XCTAssertNil(sceneIndex)
    }
    
    func testFindsSceneIndexForBlockInMiddleOfScene() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. FIRST"))
        document.appendBlock(ScreenplayBlock(element: .action, text: "Action 1"))
        document.appendBlock(ScreenplayBlock(element: .action, text: "Action 2"))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. SECOND"))
        
        let editor = ScreenplayEditor(document: document)
        let sceneIndex = await editor.sceneIndex(forBlock: 2)
        
        XCTAssertEqual(sceneIndex, 0)
    }
    
    // MARK: - Scene Filtering
    
    func testFiltersScenesByLocation() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. COFFEE SHOP - DAY"))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. CAFE - NIGHT"))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. HOUSE - DAY"))
        
        let editor = ScreenplayEditor(document: document)
        let filtered = await editor.scenes(atLocation: "COFFEE SHOP")
        
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered[0].heading, "INT. COFFEE SHOP - DAY")
    }
    
    func testFiltersScenesByTimeOfDay() async {
        var document = ScreenplayDocument()
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. HOUSE - DAY"))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. HOUSE - NIGHT"))
        document.appendBlock(ScreenplayBlock(element: .sceneHeading, text: "INT. HOUSE - MORNING"))
        
        let editor = ScreenplayEditor(document: document)
        let filtered = await editor.scenes(atTime: "DAY")
        
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered[0].heading, "INT. HOUSE - DAY")
    }
}
