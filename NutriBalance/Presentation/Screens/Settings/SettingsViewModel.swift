import Foundation
import SwiftUI

/// View model for the Settings screen.
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var user: User?
    @Published var notificationsEnabled = false
    @Published var selectedLanguage: AppLanguage = .english
    @Published var showDeleteConfirmation = false
    @Published var isLoading = false
    @Published var error: Error?

    // MARK: - Computed Properties

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    // MARK: - Dependencies

    let container: DependencyContainer

    // MARK: - Initialization

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Public Methods

    func loadUser() async {
        isLoading = true

        do {
            let repository = container.makeUserRepository()
            user = try await repository.getUser()

            // Load preferences
            notificationsEnabled = user?.notificationsEnabled ?? false
            selectedLanguage = AppLanguage(rawValue: user?.preferredLanguage ?? "en") ?? .english
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func updateNotifications(enabled: Bool) async {
        guard var currentUser = user else { return }

        do {
            currentUser.notificationsEnabled = enabled

            let repository = container.makeUserRepository()
            _ = try await repository.updateUser(currentUser)

            // Request notification permissions if enabling
            if enabled {
                await requestNotificationPermissions()
            }
        } catch {
            self.error = error
            // Revert UI
            notificationsEnabled = !enabled
        }
    }

    func exportData() {
        // TODO: Implement data export
        // This would typically generate a JSON or CSV file with all user data
    }

    func deleteAllData() async {
        isLoading = true

        do {
            // Delete all entries
            let persistenceController = container.persistenceController
            let context = persistenceController.container.viewContext

            // Delete food entries
            let foodEntryRequest = CDFoodEntry.fetchRequest()
            let foodEntries = try context.fetch(foodEntryRequest)
            for entry in foodEntries {
                context.delete(entry)
            }

            // Delete drink entries
            let drinkEntryRequest = CDDrinkEntry.fetchRequest()
            let drinkEntries = try context.fetch(drinkEntryRequest)
            for entry in drinkEntries {
                context.delete(entry)
            }

            // Delete weight entries
            let weightEntryRequest = CDWeightEntry.fetchRequest()
            let weightEntries = try context.fetch(weightEntryRequest)
            for entry in weightEntries {
                context.delete(entry)
            }

            // Delete food items
            let foodItemRequest = CDFoodItem.fetchRequest()
            let foodItems = try context.fetch(foodItemRequest)
            for item in foodItems {
                context.delete(item)
            }

            // Delete achievements
            let achievementRequest = CDAchievement.fetchRequest()
            let achievements = try context.fetch(achievementRequest)
            for achievement in achievements {
                context.delete(achievement)
            }

            try context.save()

            // Reload user
            await loadUser()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    // MARK: - Private Methods

    private func requestNotificationPermissions() async {
        // TODO: Implement notification permission request
    }
}
