import SwiftUI

@main
struct NutriBalanceApp: App {
    // MARK: - Properties

    @StateObject private var appState = AppState()
    private let persistenceController = PersistenceController.shared
    private let container: DependencyContainer

    init() {
        container = DependencyContainer(persistenceController: persistenceController)
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(appState)
                .preferredColorScheme(.light)
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
