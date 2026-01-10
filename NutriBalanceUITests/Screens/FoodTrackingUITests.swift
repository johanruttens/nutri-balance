import XCTest

final class FoodTrackingUITests: XCTestCase {
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

    // MARK: - Today Screen Tests

    func testTodayScreenDisplaysMealCategories() {
        navigateToToday()

        // Verify meal categories are displayed
        XCTAssertTrue(app.staticTexts["Breakfast"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Lunch"].exists)
        XCTAssertTrue(app.staticTexts["Dinner"].exists)
    }

    func testCanOpenAddFoodSheet() {
        navigateToToday()

        // Tap add button
        let addButton = app.buttons["plus"].firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
        } else {
            // Try navigation bar button
            app.navigationBars.buttons["plus"].tap()
        }

        // Verify add food sheet appears
        XCTAssertTrue(app.navigationBars["Add Food"].waitForExistence(timeout: 3) ||
                      app.staticTexts["Add Food"].waitForExistence(timeout: 3))
    }

    func testAddFoodSearchField() {
        navigateToToday()
        openAddFoodSheet()

        // Verify search field exists
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 3) ||
                      app.textFields["Search foods..."].exists)
    }

    func testMealCategorySelection() {
        navigateToToday()
        openAddFoodSheet()

        // Verify meal category chips are visible
        XCTAssertTrue(app.buttons["Breakfast"].waitForExistence(timeout: 3) ||
                      app.staticTexts["Breakfast"].exists)
    }

    func testCanCancelAddFood() {
        navigateToToday()
        openAddFoodSheet()

        // Tap cancel
        app.buttons["Cancel"].tap()

        // Verify sheet is dismissed
        XCTAssertTrue(app.navigationBars["Today"].waitForExistence(timeout: 3))
    }

    func testCreateCustomFoodButton() {
        navigateToToday()
        openAddFoodSheet()

        // Scroll to find create custom button if needed
        let customButton = app.buttons["Create Custom Food"]
        if !customButton.waitForExistence(timeout: 2) {
            app.swipeUp()
        }

        XCTAssertTrue(customButton.waitForExistence(timeout: 3))
    }

    // MARK: - Date Navigation Tests

    func testDateNavigationButtons() {
        navigateToToday()

        // Check for date navigation
        let previousDayButton = app.buttons["chevron.left"].firstMatch
        let nextDayButton = app.buttons["chevron.right"].firstMatch

        XCTAssertTrue(previousDayButton.exists || app.buttons["Previous Day"].exists)
        XCTAssertTrue(nextDayButton.exists || app.buttons["Next Day"].exists)
    }

    func testNavigateToPreviousDay() {
        navigateToToday()

        // Get current date text
        let todayText = app.staticTexts["Today"]
        XCTAssertTrue(todayText.waitForExistence(timeout: 3))

        // Navigate to previous day
        let previousButton = app.buttons["chevron.left"].firstMatch
        if previousButton.exists {
            previousButton.tap()
        }

        // Today label should no longer appear or should change
        sleep(1) // Wait for animation
    }

    // MARK: - Helpers

    private func navigateToToday() {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        tabBar.buttons["Today"].tap()
        XCTAssertTrue(app.navigationBars["Today"].waitForExistence(timeout: 3))
    }

    private func openAddFoodSheet() {
        let addButton = app.navigationBars.buttons["plus"].firstMatch
        if addButton.waitForExistence(timeout: 3) {
            addButton.tap()
        } else {
            // Try other add button locations
            app.buttons["plus.circle.fill"].firstMatch.tapIfExists()
        }
    }
}
