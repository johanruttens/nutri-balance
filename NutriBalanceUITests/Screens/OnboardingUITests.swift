import XCTest

final class OnboardingUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchClean()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Welcome Screen Tests

    func testWelcomeScreenDisplayed() {
        // Verify welcome screen elements
        XCTAssertTrue(app.staticTexts["NutriBalance"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Get Started"].exists)
    }

    func testGetStartedNavigatesToNameInput() {
        app.buttons["Get Started"].tap()

        // Verify name input screen
        XCTAssertTrue(app.textFields["Enter your first name"].waitForExistence(timeout: 3))
    }

    // MARK: - Name Input Tests

    func testNameInputValidation() {
        app.buttons["Get Started"].tap()

        // Next button should be disabled with empty name
        let nextButton = app.buttons["Next"]
        XCTAssertTrue(nextButton.exists)
        XCTAssertFalse(nextButton.isEnabled)

        // Enter name
        let nameField = app.textFields["Enter your first name"]
        nameField.tap()
        nameField.typeText("John")

        // Next button should now be enabled
        XCTAssertTrue(nextButton.isEnabled)
    }

    func testCanNavigateToGoalsScreen() {
        // Complete welcome
        app.buttons["Get Started"].tap()

        // Enter name
        let nameField = app.textFields["Enter your first name"]
        nameField.tap()
        nameField.typeText("TestUser")

        // Navigate to goals
        app.buttons["Next"].tap()

        // Verify goals screen
        XCTAssertTrue(app.staticTexts["Set Your Goals"].waitForExistence(timeout: 3))
    }

    // MARK: - Goals Screen Tests

    func testGoalsScreenHasRequiredElements() {
        navigateToGoalsScreen()

        // Verify goal input elements exist
        XCTAssertTrue(app.staticTexts["Current Weight"].exists)
        XCTAssertTrue(app.staticTexts["Target Weight"].exists)
    }

    // MARK: - Complete Onboarding Flow Tests

    func testCompleteOnboardingFlow() {
        // Welcome
        app.buttons["Get Started"].tap()

        // Name
        let nameField = app.textFields["Enter your first name"]
        nameField.tap()
        nameField.typeText("TestUser")
        app.buttons["Next"].tap()

        // Goals (accept defaults)
        XCTAssertTrue(app.staticTexts["Set Your Goals"].waitForExistence(timeout: 3))
        app.buttons["Next"].tap()

        // Preferences (accept defaults)
        XCTAssertTrue(app.staticTexts["Your Preferences"].waitForExistence(timeout: 3))
        app.buttons["Next"].tap()

        // Complete
        XCTAssertTrue(app.buttons["Start Tracking"].waitForExistence(timeout: 3))
        app.buttons["Start Tracking"].tap()

        // Verify main app appears
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
    }

    // MARK: - Helpers

    private func navigateToGoalsScreen() {
        app.buttons["Get Started"].tap()

        let nameField = app.textFields["Enter your first name"]
        nameField.tap()
        nameField.typeText("TestUser")

        app.buttons["Next"].tap()
    }
}
