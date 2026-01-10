import Foundation
import SwiftUI

/// ViewModel for the onboarding flow.
@MainActor
final class OnboardingViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var currentStep: Int = 0
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var currentWeight: Double = 75.0
    @Published var targetWeight: Double = 71.0
    @Published var activityLevel: ActivityLevel = .moderatelyActive
    @Published var notificationsEnabled: Bool = true
    @Published var preferredLanguage: String = "en"

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Constants

    let totalSteps = 5

    // MARK: - Dependencies

    private let container: DependencyContainer

    // MARK: - Initialization

    init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Computed Properties

    var canProceed: Bool {
        switch currentStep {
        case 0:
            return true
        case 1:
            return !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 2:
            return currentWeight > 0 && targetWeight > 0
        case 3:
            return true
        case 4:
            return true
        default:
            return false
        }
    }

    var weightDifference: Double {
        currentWeight - targetWeight
    }

    var estimatedCalorieGoal: Int {
        // Simple estimation: BMR * activity multiplier - deficit
        let bmr = 10 * currentWeight + 6.25 * 170 - 5 * 35 + 5 // Simplified BMR
        let tdee = bmr * activityLevel.multiplier
        let deficit = 500.0 // 500 kcal deficit for ~0.5kg/week loss
        return max(1200, Int(tdee - deficit))
    }

    // MARK: - Navigation

    func nextStep() {
        guard canProceed, currentStep < totalSteps - 1 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep += 1
        }
    }

    func previousStep() {
        guard currentStep > 0 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep -= 1
        }
    }

    func goToStep(_ step: Int) {
        guard step >= 0 && step < totalSteps else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = step
        }
    }

    // MARK: - Save User

    func saveUser() async {
        isLoading = true
        errorMessage = nil

        let user = User(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : lastName,
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            dailyCalorieGoal: estimatedCalorieGoal,
            dailyWaterGoal: 2000,
            activityLevel: activityLevel,
            preferredLanguage: preferredLanguage,
            notificationsEnabled: notificationsEnabled,
            onboardingCompleted: true
        )

        do {
            let createUserUseCase = container.makeCreateUserUseCase()
            _ = try await createUserUseCase.execute(user: user)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
