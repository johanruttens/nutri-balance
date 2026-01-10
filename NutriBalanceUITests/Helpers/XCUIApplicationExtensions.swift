import XCTest

extension XCUIApplication {
    /// Launches the app with specific launch arguments for testing.
    func launchForTesting() {
        launchArguments = ["--uitesting"]
        launch()
    }

    /// Launches the app in a clean state (no previous data).
    func launchClean() {
        launchArguments = ["--uitesting", "--reset-data"]
        launch()
    }

    /// Launches the app with onboarding completed.
    func launchWithOnboardingComplete() {
        launchArguments = ["--uitesting", "--onboarding-complete"]
        launch()
    }

    /// Launches the app with sample data for testing.
    func launchWithSampleData() {
        launchArguments = ["--uitesting", "--sample-data"]
        launch()
    }
}

extension XCUIElement {
    /// Waits for the element to exist with a timeout.
    @discardableResult
    func waitForExistence(timeout: TimeInterval = 5) -> Bool {
        return waitForExistence(timeout: timeout)
    }

    /// Taps the element if it exists.
    func tapIfExists(timeout: TimeInterval = 2) {
        if waitForExistence(timeout: timeout) {
            tap()
        }
    }

    /// Clears and types new text in a text field.
    func clearAndType(_ text: String) {
        guard exists else { return }
        tap()

        // Select all and delete
        if let stringValue = value as? String, !stringValue.isEmpty {
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
            typeText(deleteString)
        }

        typeText(text)
    }
}
