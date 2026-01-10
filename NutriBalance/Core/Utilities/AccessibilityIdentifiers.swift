import Foundation

/// Centralized accessibility identifiers for UI testing.
enum AccessibilityIdentifiers {

    // MARK: - Tab Bar

    enum TabBar {
        static let today = "tab.today"
        static let analytics = "tab.analytics"
        static let dashboard = "tab.dashboard"
        static let progress = "tab.progress"
        static let settings = "tab.settings"
    }

    // MARK: - Onboarding

    enum Onboarding {
        static let welcomeTitle = "onboarding.welcome.title"
        static let getStartedButton = "onboarding.getStarted"
        static let firstNameField = "onboarding.firstName"
        static let lastNameField = "onboarding.lastName"
        static let nextButton = "onboarding.next"
        static let backButton = "onboarding.back"
        static let currentWeightPicker = "onboarding.currentWeight"
        static let targetWeightPicker = "onboarding.targetWeight"
        static let startTrackingButton = "onboarding.startTracking"
    }

    // MARK: - Dashboard

    enum Dashboard {
        static let calorieRing = "dashboard.calorieRing"
        static let hydrationCard = "dashboard.hydrationCard"
        static let addFoodButton = "dashboard.addFood"
        static let addWaterButton = "dashboard.addWater"
        static let logWeightButton = "dashboard.logWeight"
        static let recentEntriesList = "dashboard.recentEntries"
    }

    // MARK: - Today

    enum Today {
        static let dateSelector = "today.dateSelector"
        static let previousDayButton = "today.previousDay"
        static let nextDayButton = "today.nextDay"
        static let summaryHeader = "today.summaryHeader"
        static let mealSection = "today.mealSection"
        static let addEntryButton = "today.addEntry"
    }

    // MARK: - Add Food

    enum AddFood {
        static let searchField = "addFood.searchField"
        static let mealCategoryPicker = "addFood.mealPicker"
        static let recentSection = "addFood.recentSection"
        static let favoritesSection = "addFood.favoritesSection"
        static let searchResults = "addFood.searchResults"
        static let createCustomButton = "addFood.createCustom"
        static let portionSizeField = "addFood.portionSize"
        static let portionUnitPicker = "addFood.portionUnit"
        static let addButton = "addFood.add"
        static let cancelButton = "addFood.cancel"
    }

    // MARK: - Hydration

    enum Hydration {
        static let progressRing = "hydration.progressRing"
        static let goalLabel = "hydration.goalLabel"
        static let intakeLabel = "hydration.intakeLabel"
        static let quickAddButtons = "hydration.quickAdd"
        static let drinksList = "hydration.drinksList"
    }

    // MARK: - Progress

    enum Progress {
        static let currentWeightLabel = "progress.currentWeight"
        static let targetWeightLabel = "progress.targetWeight"
        static let weightChart = "progress.weightChart"
        static let logWeightButton = "progress.logWeight"
        static let bmiCard = "progress.bmiCard"
        static let statisticsCard = "progress.statistics"
    }

    // MARK: - Analytics

    enum Analytics {
        static let periodPicker = "analytics.periodPicker"
        static let calorieChart = "analytics.calorieChart"
        static let macroBreakdown = "analytics.macroBreakdown"
        static let goalProgress = "analytics.goalProgress"
        static let exportButton = "analytics.export"
    }

    // MARK: - Settings

    enum Settings {
        static let profileRow = "settings.profileRow"
        static let goalsRow = "settings.goalsRow"
        static let notificationsToggle = "settings.notifications"
        static let languagePicker = "settings.language"
        static let exportDataButton = "settings.exportData"
        static let deleteDataButton = "settings.deleteData"
        static let privacyPolicyRow = "settings.privacyPolicy"
        static let aboutRow = "settings.about"
    }

    // MARK: - Common

    enum Common {
        static let loadingIndicator = "common.loading"
        static let errorView = "common.error"
        static let emptyState = "common.emptyState"
        static let retryButton = "common.retry"
    }
}
