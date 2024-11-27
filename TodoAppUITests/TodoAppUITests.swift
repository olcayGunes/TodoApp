import XCTest

final class TodoAppUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-UIInterfaceOrientation", "UIInterfaceOrientationPortrait"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func testAddNewTodo() {
        // Başlık gir
        let titleTextField = app.textFields["titleTextField"]
        XCTAssertTrue(titleTextField.waitForExistence(timeout: 5))
        
        titleTextField.tap()
        titleTextField.typeText("Test Todo")
        
        // Açıklama gir
        let descriptionTextEditor = app.textViews["descriptionTextEditor"]
        descriptionTextEditor.tap()
        descriptionTextEditor.typeText("Test açıklama")
        
        // Öncelik seç
        app.segmentedControls["priorityPicker"].buttons["Yüksek"].tap()
        
        // Hatırlatıcı ekle
        app.switches["reminderToggle"].tap()
        
        // Ekle butonuna tıkla
        app.buttons["addButton"].tap()
        
        // Eklenen todo'yu kontrol et
        let addedTodo = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Test Todo")).firstMatch
        XCTAssertTrue(addedTodo.exists)
    }
}
