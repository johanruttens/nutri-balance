import SwiftUI

@main
struct NutriBalanceApp: App {
    // MARK: - Properties

    @StateObject private var appState = AppState()
    @ObservedObject private var localizationManager = LocalizationManager.shared
    private let persistenceController = PersistenceController.shared
    private let container = DependencyContainer.shared

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(appState)
                .environmentObject(localizationManager)
                .preferredColorScheme(.light)
                .id(localizationManager.currentLanguage.rawValue)
                .withToast()
                .task {
                    // Seed food database on first launch
                    let seeder = FoodDataSeeder(context: persistenceController.viewContext)
                    await seeder.seedIfNeeded()
                }
        }
    }
}

// MARK: - App State

@MainActor
final class AppState: ObservableObject {
    @Published var isOnboardingComplete: Bool
    @Published var currentUser: User?

    private let userDefaults = UserDefaults.standard
    private let onboardingKey = "hasCompletedOnboarding"

    init() {
        self.isOnboardingComplete = userDefaults.bool(forKey: onboardingKey)
        self.currentUser = nil
    }

    func completeOnboarding() {
        isOnboardingComplete = true
        userDefaults.set(true, forKey: onboardingKey)
    }

    func resetOnboarding() {
        isOnboardingComplete = false
        userDefaults.set(false, forKey: onboardingKey)
        currentUser = nil
    }
}
