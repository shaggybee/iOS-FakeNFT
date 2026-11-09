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
    func testMyNFTLikeChangesUpdateFavoritesAndProfileCounter() throws {
        let app = favoritesApp()
        app.launch()
        XCTAssertTrue(app.buttons["profile.my-nfts"].waitForExistence(timeout: 10))
        app.buttons["profile.my-nfts"].tap()
        let add = app.buttons["profile.nfts.favorite.1"]
        let remove = app.buttons["profile.nfts.favorite.2"]
        XCTAssertTrue(add.waitForExistence(timeout: 10))
        XCTAssertEqual(add.value as? String, "Не в избранном")
        add.tap()
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        XCTAssertTrue(NSPredicate(format: "value == %@", "В избранном").evaluate(with: add)
                      || XCTWaiter.wait(for: [XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "В избранном"), object: add)], timeout: 5) == .completed)
        remove.tap()
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "Не в избранном"), object: remove)], timeout: 5), .completed)
        attachScreenshot("Мои NFT — изменение избранного")
        app.buttons["profile.nfts.back"].tap()
        let favorites = app.buttons["profile.favorites"]
        XCTAssertTrue(favorites.waitForExistence(timeout: 5))
        XCTAssertTrue(favorites.label.contains("(2)"))
        favorites.tap()
        XCTAssertTrue(app.buttons["profile.favorites.remove.1"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["profile.favorites.remove.2"].exists)
        app.buttons["profile.favorites.back"].tap()
        app.buttons["profile.my-nfts"].tap()
        XCTAssertTrue(add.waitForExistence(timeout: 5))
        XCTAssertEqual(add.value as? String, "В избранном")
        XCTAssertEqual(remove.value as? String, "Не в избранном")
    }

    @MainActor
    func testMyNFTLikeFailureCanRetryWithoutLosingList() throws {
        let app = favoritesApp(["--profile-favorites-fail-first-removal"])
        app.launch()
        XCTAssertTrue(app.buttons["profile.my-nfts"].waitForExistence(timeout: 10))
        app.buttons["profile.my-nfts"].tap()
        let heart = app.buttons["profile.nfts.favorite.1"]
        XCTAssertTrue(heart.waitForExistence(timeout: 10))
        heart.tap()
        let alert = app.alerts["Не удалось обновить избранное"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        attachScreenshot("Ошибка изменения избранного в Моих NFT")
        alert.buttons["Повторить"].tap()
        XCTAssertEqual(XCTWaiter.wait(for: [XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", "В избранном"), object: heart)], timeout: 5), .completed)
        XCTAssertEqual(app.staticTexts.matching(identifier: "profile.nfts.name").count, 3)
        app.buttons["profile.nfts.back"].tap()
        XCTAssertTrue(app.buttons["profile.favorites"].label.contains("(3)"))
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
    func testDefaultDebugDemoCanBeViewedWithoutAPI() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launch()
        let catalogError = app.alerts.firstMatch
        if catalogError.exists, catalogError.buttons["Отмена"].exists {
            catalogError.buttons["Отмена"].tap()
        }
        let profileTab = app.tabBars.buttons["Профиль"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()
        XCTAssertTrue(app.staticTexts["profile.name"].waitForExistence(timeout: 10))
        attachScreenshot("Демонстрационный профиль")
        app.buttons["profile.my-nfts"].tap()
        XCTAssertTrue(app.staticTexts.matching(identifier: "profile.nfts.name").firstMatch.waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts.matching(identifier: "profile.nfts.name").count, 3)
        attachScreenshot("Демонстрационные NFT с локальными изображениями")
        app.buttons["profile.nfts.back"].tap()
        let edit = app.buttons["profile.edit"]
        XCTAssertTrue(edit.waitForExistence(timeout: 5))
        XCTAssertTrue(edit.isHittable)
        edit.tap()
        XCTAssertTrue(app.textFields["profile.edit.name"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testMyNFTAlertRetryLoadsItems() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--profile-ui-testing", "--profile-nfts-fail-first-load", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launch()
        XCTAssertTrue(app.buttons["profile.my-nfts"].waitForExistence(timeout: 10))
        app.buttons["profile.my-nfts"].tap()
        let alert = app.alerts["Не удалось загрузить NFT"]
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
        alert.buttons["Повторить"].tap()
        XCTAssertTrue(app.staticTexts.matching(identifier: "profile.nfts.name").firstMatch.waitForExistence(timeout: 10))
    }

    @MainActor
    func testLeavingDuringNFTRetryAllowsReopeningScreen() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--profile-ui-testing", "--profile-nfts-fail-first-load", "--profile-nfts-slow-retry",
                               "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"]
        app.launch()
        let link = app.buttons["profile.my-nfts"]
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        link.tap()
        let alert = app.alerts["Не удалось загрузить NFT"]
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
        alert.buttons["Повторить"].tap()
        XCTAssertTrue(app.activityIndicators.firstMatch.waitForExistence(timeout: 5))
        app.buttons["profile.nfts.back"].tap()
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.tap()
        XCTAssertTrue(app.staticTexts.matching(identifier: "profile.nfts.name").firstMatch.waitForExistence(timeout: 10))
        XCTAssertFalse(app.alerts["Не удалось загрузить NFT"].exists)
    }

    @MainActor
    func testFavoritesRemovalUpdatesProfileAndEmptyState() throws {
        let app = favoritesApp()
        app.launch()
        let link = app.buttons["profile.favorites"]
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        XCTAssertTrue(link.label.contains("(2)"))
        link.tap()
        let spring = app.buttons["profile.favorites.remove.2"]
        XCTAssertTrue(spring.waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts.matching(identifier: "profile.favorites.name").count, 2)
        attachScreenshot("Избранные NFT")
        spring.tap()
        XCTAssertTrue(spring.waitForNonExistence(timeout: 10))
        app.buttons["profile.favorites.back"].tap()
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        XCTAssertTrue(link.label.contains("(1)"))
        app.buttons["profile.my-nfts"].tap()
        XCTAssertTrue(app.staticTexts.matching(identifier: "profile.nfts.name").firstMatch.waitForExistence(timeout: 10))
        app.buttons["profile.nfts.back"].tap()
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        link.tap()
        let charm = app.buttons["profile.favorites.remove.5"]
        XCTAssertTrue(charm.waitForExistence(timeout: 10))
        charm.tap()
        XCTAssertTrue(app.staticTexts["У Вас ещё нет избранных NFT"].waitForExistence(timeout: 10))
        attachScreenshot("Избранное после удаления последнего NFT")
        app.buttons["profile.favorites.back"].tap()
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        XCTAssertTrue(link.label.contains("(0)"))
        XCTAssertTrue(app.tabBars.buttons["Каталог"].exists)
        attachScreenshot("Счётчик избранного обновлён")
    }

    @MainActor
    func testFavoritesEmptyStateAndBackNavigation() throws {
        let app = favoritesApp(["--profile-empty-favorites"])
        app.launch()
        XCTAssertTrue(app.buttons["profile.favorites"].waitForExistence(timeout: 10))
        app.buttons["profile.favorites"].tap()
        XCTAssertTrue(app.staticTexts["У Вас ещё нет избранных NFT"].waitForExistence(timeout: 10))
        attachScreenshot("Нет избранных NFT")
        app.buttons["profile.favorites.back"].tap()
        XCTAssertTrue(app.buttons["profile.my-nfts"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testFavoritesLoadFailureCanRetry() throws {
        let app = favoritesApp(["--profile-favorites-fail-first-load"])
        app.launch()
        XCTAssertTrue(app.buttons["profile.favorites"].waitForExistence(timeout: 10))
        app.buttons["profile.favorites"].tap()
        let alert = app.alerts["Не удалось обновить избранное"]
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
        attachScreenshot("Ошибка загрузки избранного")
        alert.buttons["Повторить"].tap()
        XCTAssertTrue(app.buttons["profile.favorites.remove.2"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testFavoritesRemovalFailureKeepsCardAndRetriesMutation() throws {
        let app = favoritesApp(["--profile-favorites-fail-first-removal"])
        app.launch()
        XCTAssertTrue(app.buttons["profile.favorites"].waitForExistence(timeout: 10))
        app.buttons["profile.favorites"].tap()
        let remove = app.buttons["profile.favorites.remove.2"]
        XCTAssertTrue(remove.waitForExistence(timeout: 10))
        remove.tap()
        let alert = app.alerts["Не удалось обновить избранное"]
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts.matching(identifier: "profile.favorites.name").count, 2)
        attachScreenshot("Ошибка удаления из избранного")
        alert.buttons["Повторить"].tap()
        XCTAssertTrue(remove.waitForNonExistence(timeout: 10))
        XCTAssertEqual(app.staticTexts.matching(identifier: "profile.favorites.name").count, 1)
    }

    @MainActor
    func testFavoritesRemovalFailureCanBeCancelledWithoutLosingCard() throws {
        let app = favoritesApp(["--profile-favorites-fail-first-removal"])
        app.launch()
        XCTAssertTrue(app.buttons["profile.favorites"].waitForExistence(timeout: 10))
        app.buttons["profile.favorites"].tap()
        let remove = app.buttons["profile.favorites.remove.2"]
        XCTAssertTrue(remove.waitForExistence(timeout: 10))
        remove.tap()
        let alert = app.alerts["Не удалось обновить избранное"]
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
        alert.buttons["Отмена"].tap()
        XCTAssertTrue(remove.exists)
        app.buttons["profile.favorites.back"].tap()
        let link = app.buttons["profile.favorites"]
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        XCTAssertTrue(link.label.contains("(2)"))
    }

    @MainActor
    private func favoritesApp(_ arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--profile-ui-testing", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU"] + arguments
        return app
    }

    @MainActor
    private func attachScreenshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

extension iOS_FakeNFT_ExtendedUITests {
    @MainActor
    func testCompleteProfileEpicScreencast() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--profile-ui-testing", "--profile-unavailable-website", "-AppleLanguages", "(ru)", "-AppleLocale", "ru_RU", "-Profile.myNFTs.sort", "rating"]
        app.launch()
        XCTAssertTrue(app.staticTexts["profile.name"].waitForExistence(timeout: 10))
        attachScreenshot("Integrated profile")
        app.buttons["profile.edit"].tap()
        let name = app.textFields["profile.edit.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        let previous = (name.value as? String) ?? ""
        name.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: previous.count) + "Anton")
        attachScreenshot("Integrated profile editing")
        app.buttons["profile.edit.save"].tap()
        XCTAssertTrue(app.staticTexts["profile.name"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["profile.name"].label, "Anton")
        app.buttons["profile.website"].tap()
        XCTAssertTrue(app.buttons["profile.website.retry"].waitForExistence(timeout: 10))
        attachScreenshot("Integrated website error handling")
        app.buttons["Готово"].tap()
        app.buttons["profile.my-nfts"].tap()
        XCTAssertTrue(app.staticTexts.matching(identifier: "profile.nfts.name").firstMatch.waitForExistence(timeout: 10))
        attachScreenshot("Integrated owned NFTs")
        app.buttons["profile.nfts.sort"].tap()
        app.buttons["По цене"].tap()
        attachScreenshot("Integrated sorting")
        app.buttons["profile.nfts.back"].tap()
        app.buttons["profile.favorites"].tap()
        let remove = app.buttons["profile.favorites.remove.2"]
        XCTAssertTrue(remove.waitForExistence(timeout: 10))
        attachScreenshot("Integrated favorites")
        remove.tap()
        XCTAssertTrue(remove.waitForNonExistence(timeout: 10))
        app.buttons["profile.favorites.remove.5"].tap()
        XCTAssertTrue(app.staticTexts["У Вас ещё нет избранных NFT"].waitForExistence(timeout: 10))
        attachScreenshot("Integrated empty favorites")
        app.buttons["profile.favorites.back"].tap()
        XCTAssertTrue(app.buttons["profile.favorites"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["profile.favorites"].label.contains("(0)"))
        XCTAssertTrue(app.tabBars.buttons["Каталог"].exists)
        XCTAssertTrue(app.tabBars.buttons["Корзина"].exists)
        attachScreenshot("Integrated updated profile counter")
    }
}
