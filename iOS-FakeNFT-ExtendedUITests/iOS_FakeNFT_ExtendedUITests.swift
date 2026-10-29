import XCTest

final class iOS_FakeNFT_ExtendedUITests: XCTestCase {
    @MainActor
    func testProfileEditingAndSaving() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--profile-ui-testing", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launch()
        XCTAssertTrue(app.staticTexts["profile.name"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.buttons["profile.my-nfts"].label, "Мои NFT (3)")
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
    func testUnavailableWebsiteShowsRetryAndCanBeClosed() throws {
        let app = XCUIApplication()
        // The fixture uses a local unavailable address without changing a real profile.
        app.launchArguments = ["--profile-ui-testing", "--profile-unavailable-website", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launch()
        let link = app.buttons["profile.website"]
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        XCTAssertEqual(link.label, "https://127.0.0.1:65534")
        link.tap()
        let retry = app.buttons["profile.website.retry"]
        XCTAssertTrue(retry.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Не удалось открыть сайт"].exists)
        attachScreenshot("Ошибка открытия сайта")
        retry.tap()
        XCTAssertTrue(retry.waitForExistence(timeout: 10))
        app.buttons["Готово"].tap()
        XCTAssertTrue(app.staticTexts["profile.name"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testMyNFTSortingPersistsAfterRelaunch() throws {
        let app = XCUIApplication()
        let arguments = ["--profile-ui-testing", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launchArguments = arguments + ["-Profile.myNFTs.sort", "rating"]
        app.launch()
        let link = app.buttons["profile.my-nfts"]
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        link.tap()
        let names = app.staticTexts.matching(identifier: "profile.nfts.name")
        XCTAssertTrue(names.firstMatch.waitForExistence(timeout: 10))
        XCTAssertEqual(names.allElementsBoundByIndex.map(\.label), ["Spring", "April", "Lilo"])
        attachScreenshot("Мои NFT")
        let sort = app.buttons["profile.nfts.sort"]
        sort.tap()
        attachScreenshot("Сортировка NFT")
        app.buttons["По названию"].tap()
        XCTAssertEqual(names.allElementsBoundByIndex.map(\.label), ["April", "Lilo", "Spring"])
        sort.tap()
        app.buttons["По цене"].tap()
        XCTAssertEqual(sort.value as? String, "По цене")
        XCTAssertEqual(names.allElementsBoundByIndex.map(\.label), ["April", "Lilo", "Spring"])
        attachScreenshot("Мои NFT после сортировки")

        app.terminate()
        app.launchArguments = arguments
        app.launch()
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        link.tap()
        XCTAssertTrue(sort.waitForExistence(timeout: 10))
        XCTAssertEqual(sort.value as? String, "По цене")
        XCTAssertEqual(names.allElementsBoundByIndex.map(\.label), ["April", "Lilo", "Spring"])
        app.buttons["profile.nfts.back"].tap()
        XCTAssertTrue(app.buttons["profile.my-nfts"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Каталог"].exists)
    }

    @MainActor
    func testMyNFTEmptyStateAndBackNavigation() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--profile-ui-testing", "--profile-empty-nfts", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launch()
        let link = app.buttons["profile.my-nfts"]
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        XCTAssertEqual(link.label, "Мои NFT (0)")
        link.tap()
        XCTAssertTrue(app.staticTexts["У Вас ещё нет NFT"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["profile.nfts.sort"].exists)
        attachScreenshot("Нет NFT")
        app.buttons["profile.nfts.back"].tap()
        XCTAssertTrue(link.waitForExistence(timeout: 5))
    }

    @MainActor
    func testMyNFTLoadFailureCanBeDismissedAndRetried() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--profile-ui-testing", "--profile-nfts-fail-first-load", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launch()
        let link = app.buttons["profile.my-nfts"]
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        link.tap()
        let alert = app.alerts["Не удалось загрузить NFT"]
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
        attachScreenshot("Ошибка загрузки NFT")
        alert.buttons["Отмена"].tap()
        let retry = app.buttons["Повторить"]
        XCTAssertTrue(retry.waitForExistence(timeout: 5))
        retry.tap()
        XCTAssertTrue(app.staticTexts.matching(identifier: "profile.nfts.name").firstMatch.waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts.matching(identifier: "profile.nfts.name").count, 3)
    }

    @MainActor
    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
