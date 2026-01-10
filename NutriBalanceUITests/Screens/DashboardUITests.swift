import XCTest

final class DashboardUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchWithOnboardingComplete()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Tab Bar Tests

    func testTabBarDisplayed() {
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }

    func testAllTabsExist() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        XCTAssertTrue(tabBar.buttons["Today"].exists)
        XCTAssertTrue(tabBar.buttons["Analytics"].exists)
        XCTAssertTrue(tabBar.buttons["Dashboard"].exists)
        XCTAssertTrue(tabBar.buttons["Progress"].exists)
        XCTAssertTrue(tabBar.buttons["Settings"].exists)
    }

    func testTabNavigation() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        // Navigate to each tab
        tabBar.buttons["Today"].tap()
        XCTAssertTrue(app.navigationBars["Today"].waitForExistence(timeout: 3))

        tabBar.buttons["Analytics"].tap()
        XCTAssertTrue(app.navigationBars["Analytics"].waitForExistence(timeout: 3))

        tabBar.buttons["Progress"].tap()
        XCTAssertTrue(app.navigationBars["Progress"].waitForExistence(timeout: 3))

        tabBar.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))
    }

    // MARK: - Dashboard Content Tests

    func testDashboardShowsCalorieSummary() {
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["Dashboard"].tap()

        // Dashboard should show calorie information
        XCTAssertTrue(app.staticTexts["kcal"].waitForExistence(timeout: 3))
    }

    func testDashboardShowsQuickActions() {
        let tabBar = app.tabBars.firstMatch
        tabBar.buttons["Dashboard"].tap()

        // Should have quick action buttons
        XCTAssertTrue(app.buttons["Add Food"].waitForExistence(timeout: 3) ||
                      app.buttons["add.food"].exists)
    }
}
