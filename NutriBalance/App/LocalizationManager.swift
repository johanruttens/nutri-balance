import Foundation
import SwiftUI

// MARK: - App Language

/// Supported languages in the app.
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case dutch = "nl"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .dutch: return "Nederlands"
        }
    }
}

// MARK: - Localization Manager

/// Manages app localization with runtime language switching support.
final class LocalizationManager: ObservableObject {

    // MARK: - Singleton

    static let shared = LocalizationManager()

    // MARK: - Published Properties

    @Published private(set) var currentLanguage: AppLanguage {
        didSet {
            updateBundle()
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
        }
    }

    // MARK: - Properties

    private(set) var bundle: Bundle = .main

    // MARK: - Initialization

    private init() {
        // Load saved language or use system default
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // Check system language
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = AppLanguage(rawValue: systemLanguage) ?? .english
        }
        updateBundle()
    }

    // MARK: - Public Methods

    /// Sets the app language and updates all localized content.
    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language

        // Also update AppleLanguages for consistency with system
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()

        // Post notification for non-SwiftUI components
        NotificationCenter.default.post(name: .languageDidChange, object: language)
    }

    /// Returns a localized string for the given key.
    func localizedString(_ key: String, defaultValue: String? = nil) -> String {
        let value = bundle.localizedString(forKey: key, value: defaultValue ?? key, table: "Localizable")
        return value
    }

    /// Returns a localized string with format arguments.
    func localizedString(_ key: String, _ arguments: CVarArg...) -> String {
        let format = localizedString(key)
        return String(format: format, arguments: arguments)
    }

    // MARK: - Private Methods

    private func updateBundle() {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            self.bundle = .main
            return
        }
        self.bundle = bundle
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let languageDidChange = Notification.Name("languageDidChange")
}

// MARK: - SwiftUI Environment

private struct LocalizationManagerKey: EnvironmentKey {
    static let defaultValue = LocalizationManager.shared
}

extension EnvironmentValues {
    var localizationManager: LocalizationManager {
        get { self[LocalizationManagerKey.self] }
        set { self[LocalizationManagerKey.self] = newValue }
    }
}

// MARK: - String Extension for Localization

extension String {
    /// Returns the localized version of this string using the current app language.
    var localized: String {
        LocalizationManager.shared.localizedString(self)
    }

    /// Returns the localized version with format arguments.
    func localized(_ arguments: CVarArg...) -> String {
        let format = LocalizationManager.shared.localizedString(self)
        return String(format: format, arguments: arguments)
    }
}

// MARK: - View Modifier for Language Updates

struct LocalizedViewModifier: ViewModifier {
    @ObservedObject private var localizationManager = LocalizationManager.shared

    func body(content: Content) -> some View {
        content
            .id(localizationManager.currentLanguage.rawValue)
    }
}

extension View {
    /// Forces view to update when language changes.
    func localizedView() -> some View {
        modifier(LocalizedViewModifier())
    }
}

// MARK: - Localized Text Helper

/// SwiftUI Text that uses the current app language bundle.
struct LocalizedText: View {
    let key: String
    let tableName: String?
    @ObservedObject private var localizationManager = LocalizationManager.shared

    init(_ key: String, tableName: String? = nil) {
        self.key = key
        self.tableName = tableName
    }

    var body: some View {
        Text(NSLocalizedString(key, tableName: tableName, bundle: localizationManager.bundle, comment: ""))
    }
}

// MARK: - Localization Helper Function

/// Returns a localized string using the current app language.
func L(_ key: String) -> String {
    LocalizationManager.shared.localizedString(key)
}

// MARK: - Date Formatting Helpers

extension LocalizationManager {
    /// Returns the current locale based on selected language
    var currentLocale: Locale {
        Locale(identifier: currentLanguage.rawValue)
    }

    /// Formats a date with weekday, month and day (e.g., "Monday, January 15")
    func formatDateFull(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.setLocalizedDateFormatFromTemplate("EEEEMMMMd")
        return formatter.string(from: date)
    }

    /// Formats a date with short weekday (e.g., "Mon")
    func formatWeekdayShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    /// Formats a date with day and month (e.g., "15 Jan")
    func formatDayMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.setLocalizedDateFormatFromTemplate("dMMM")
        return formatter.string(from: date)
    }

    /// Formats a date in medium style (e.g., "Jan 15, 2024")
    func formatDateMedium(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    /// Formats time (e.g., "14:30" or "2:30 PM")
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

/// Formats a date using the current app language
func LDate(_ date: Date, style: LocalizedDateStyle = .full) -> String {
    switch style {
    case .full:
        return LocalizationManager.shared.formatDateFull(date)
    case .weekdayShort:
        return LocalizationManager.shared.formatWeekdayShort(date)
    case .dayMonth:
        return LocalizationManager.shared.formatDayMonth(date)
    case .medium:
        return LocalizationManager.shared.formatDateMedium(date)
    case .time:
        return LocalizationManager.shared.formatTime(date)
    }
}

enum LocalizedDateStyle {
    case full       // Monday, January 15
    case weekdayShort // Mon
    case dayMonth   // 15 Jan
    case medium     // Jan 15, 2024
    case time       // 14:30
}
