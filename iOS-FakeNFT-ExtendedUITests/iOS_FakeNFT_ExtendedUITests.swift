import XCTest

final class iOS_FakeNFT_ExtendedUITests: XCTestCase {
    @MainActor
    func testProfileEditingAndSaving() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--profile-ui-testing", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launch()
        XCTAssertTrue(app.staticTexts["profile.name"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Мои NFT (3)"].exists)
        attachScreenshot("Профиль")
        app.buttons["profile.edit"].tap()
        let name = app.textFields["profile.edit.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        attachScreenshot("Редактирование")
        name.tap()
        let old = (name.value as? String) ?? ""
        name.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: old.count) + "Anton")
        app.buttons["profile.edit.save"].tap()
        XCTAssertTrue(app.staticTexts["profile.name"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["profile.name"].label, "Anton")
        attachScreenshot("После сохранения")
    }

    @MainActor
    func testServerFailureOffersRetryAndLoadsProfile() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--profile-ui-testing", "--profile-fail-first-load", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launch()
        let alert = app.alerts["Не удалось загрузить профиль"]
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
        attachScreenshot("Ошибка загрузки")
        alert.buttons["Повторить"].tap()
        XCTAssertTrue(app.staticTexts["profile.name"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLeavingEditorDiscardsUnsavedChangesOnlyAfterConfirmation() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--profile-ui-testing", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launch()
        XCTAssertTrue(app.buttons["profile.edit"].waitForExistence(timeout: 10))
        app.buttons["profile.edit"].tap()
        let name = app.textFields["profile.edit.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText(" Test")
        app.buttons["profile.edit.back"].tap()
        let confirmation = app.alerts["Выйти без сохранения?"]
        XCTAssertTrue(confirmation.waitForExistence(timeout: 5))
        confirmation.buttons["Выйти"].tap()
        XCTAssertTrue(app.staticTexts["profile.name"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["profile.name"].label, "Студент Практикума")
    }

    @MainActor
    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
