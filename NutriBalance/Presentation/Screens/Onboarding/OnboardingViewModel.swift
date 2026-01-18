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
    @Published var preferredLanguage: String = LocalizationManager.shared.currentLanguage.rawValue
    @Published var selectedLanguage: AppLanguage = LocalizationManager.shared.currentLanguage

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

    // MARK: - Validation Constants

    private enum ValidationConstants {
        static let minWeight: Double = 20.0
        static let maxWeight: Double = 500.0
        static let minNameLength: Int = 1
        static let maxNameLength: Int = 50
    }

    // MARK: - Computed Properties

    var canProceed: Bool {
        switch currentStep {
        case 0:
            return true
        case 1:
            return isValidName(firstName)
        case 2:
            return isValidWeight(currentWeight) && isValidWeight(targetWeight)
        case 3:
            return true
        case 4:
            return true
        default:
            return false
        }
    }

    /// Validation error message for current step
    var validationError: String? {
        switch currentStep {
        case 1:
            if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return L("validation.nameRequired")
            }
            if firstName.count > ValidationConstants.maxNameLength {
                return L("validation.nameTooLong")
            }
            return nil
        case 2:
            if !isValidWeight(currentWeight) {
                return L("validation.invalidWeight")
            }
            if !isValidWeight(targetWeight) {
                return L("validation.invalidTargetWeight")
            }
            return nil
        default:
            return nil
        }
    }

    // MARK: - Validation Methods

    private func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= ValidationConstants.minNameLength &&
               trimmed.count <= ValidationConstants.maxNameLength
    }

    private func isValidWeight(_ weight: Double) -> Bool {
        return weight >= ValidationConstants.minWeight &&
               weight <= ValidationConstants.maxWeight
    }

    /// Sanitize input before saving
    private func sanitizedFirstName() -> String {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func sanitizedLastName() -> String? {
        let trimmed = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
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
        // Validate before saving
        guard canProceed else {
            errorMessage = validationError ?? L("validation.genericError")
            return
        }

        isLoading = true
        errorMessage = nil

        // Clamp weight values to valid range
        let safeCurrentWeight = max(ValidationConstants.minWeight, min(ValidationConstants.maxWeight, currentWeight))
        let safeTargetWeight = max(ValidationConstants.minWeight, min(ValidationConstants.maxWeight, targetWeight))

        let user = User(
            firstName: sanitizedFirstName(),
            lastName: sanitizedLastName(),
            currentWeight: safeCurrentWeight,
            targetWeight: safeTargetWeight,
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
