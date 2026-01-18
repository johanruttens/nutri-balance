import Foundation

/// Represents a user of the NutriBalance app.
/// Contains personal information, goals, and preferences.
struct User: Identifiable, Equatable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String?
    var profileImageData: Data?
    var email: String?

    // MARK: - Physical Attributes

    var currentWeight: Double // in kg
    var targetWeight: Double // in kg
    var height: Double? // in cm
    var birthDate: Date?

    // MARK: - Goals

    var targetDate: Date?
    var dailyCalorieGoal: Int
    var dailyWaterGoal: Double // in ml
    var targetProtein: Double? // in grams
    var targetCarbs: Double? // in grams
    var targetFat: Double? // in grams

    // MARK: - Activity

    var activityLevel: ActivityLevel

    // MARK: - Preferences

    var preferredLanguage: String
    var notificationsEnabled: Bool
    var mealReminderTimes: [MealCategory: Date]?

    // MARK: - Metadata

    var createdAt: Date
    var updatedAt: Date
    var onboardingCompleted: Bool

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String? = nil,
        profileImageData: Data? = nil,
        email: String? = nil,
        currentWeight: Double,
        targetWeight: Double,
        height: Double? = nil,
        birthDate: Date? = nil,
        targetDate: Date? = nil,
        dailyCalorieGoal: Int = 2000,
        dailyWaterGoal: Double = 2000,
        targetProtein: Double? = nil,
        targetCarbs: Double? = nil,
        targetFat: Double? = nil,
        activityLevel: ActivityLevel = .moderatelyActive,
        preferredLanguage: String = "en",
        notificationsEnabled: Bool = true,
        mealReminderTimes: [MealCategory: Date]? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        onboardingCompleted: Bool = false
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageData = profileImageData
        self.email = email
        self.currentWeight = currentWeight
        self.targetWeight = targetWeight
        self.height = height
        self.birthDate = birthDate
        self.targetDate = targetDate
        self.dailyCalorieGoal = dailyCalorieGoal
        self.dailyWaterGoal = dailyWaterGoal
        self.targetProtein = targetProtein
        self.targetCarbs = targetCarbs
        self.targetFat = targetFat
        self.activityLevel = activityLevel
        self.preferredLanguage = preferredLanguage
        self.notificationsEnabled = notificationsEnabled
        self.mealReminderTimes = mealReminderTimes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.onboardingCompleted = onboardingCompleted
    }

    // MARK: - Computed Properties

    /// Full display name
    var displayName: String {
        if let lastName = lastName, !lastName.isEmpty {
            return "\(firstName) \(lastName)"
        }
        return firstName
    }

    /// Weight difference from target
    var weightToLose: Double {
        currentWeight - targetWeight
    }

    /// Progress towards weight goal (0.0 to 1.0)
    var weightProgress: Double {
        guard weightToLose > 0 else { return 1.0 }
        let initialWeight = currentWeight + (targetWeight - currentWeight)
        let totalToLose = initialWeight - targetWeight
        guard totalToLose > 0 else { return 1.0 }
        return min(1.0, max(0.0, (initialWeight - currentWeight) / totalToLose))
    }

    /// Calculate BMI if height is available
    var bmi: Double? {
        guard let height = height, height > 0 else { return nil }
        let heightInMeters = height / 100
        return currentWeight / (heightInMeters * heightInMeters)
    }

    /// BMI category description
    var bmiCategory: String? {
        guard let bmi = bmi else { return nil }
        switch bmi {
        case ..<18.5:
            return L("bmi.underweight")
        case 18.5..<25:
            return L("bmi.normal")
        case 25..<30:
            return L("bmi.overweight")
        default:
            return L("bmi.obese")
        }
    }

    /// Calculate age if birth date is available
    var age: Int? {
        guard let birthDate = birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year
    }

    /// Estimated TDEE (Total Daily Energy Expenditure)
    var estimatedTDEE: Int {
        // Using Mifflin-St Jeor Equation
        guard let height = height, let age = age else {
            return dailyCalorieGoal
        }

        // Assuming male for now, could be enhanced with gender property
        let bmr = 10 * currentWeight + 6.25 * height - 5 * Double(age) + 5
        return Int(bmr * activityLevel.multiplier)
    }
}

// MARK: - Activity Level

enum ActivityLevel: Int16, CaseIterable, Identifiable, Codable {
    case sedentary = 0
    case lightlyActive = 1
    case moderatelyActive = 2
    case veryActive = 3
    case extraActive = 4

    var id: Int16 { rawValue }

    var displayName: String {
        switch self {
        case .sedentary:
            return L("activity.sedentary")
        case .lightlyActive:
            return L("activity.lightlyActive")
        case .moderatelyActive:
            return L("activity.moderatelyActive")
        case .veryActive:
            return L("activity.veryActive")
        case .extraActive:
            return L("activity.extraActive")
        }
    }

    var description: String {
        switch self {
        case .sedentary:
            return L("activity.sedentary.description")
        case .lightlyActive:
            return L("activity.lightlyActive.description")
        case .moderatelyActive:
            return L("activity.moderatelyActive.description")
        case .veryActive:
            return L("activity.veryActive.description")
        case .extraActive:
            return L("activity.extraActive.description")
        }
    }

    var multiplier: Double {
        switch self {
        case .sedentary:
            return 1.2
        case .lightlyActive:
            return 1.375
        case .moderatelyActive:
            return 1.55
        case .veryActive:
            return 1.725
        case .extraActive:
            return 1.9
        }
    }
}

// MARK: - Mock Data

extension User {
    static var mock: User {
        User(
            firstName: "Johan",
            lastName: "Ruttens",
            currentWeight: 85.0,
            targetWeight: 81.0,
            height: 180,
            birthDate: Calendar.current.date(byAdding: .year, value: -35, to: Date()),
            targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
            dailyCalorieGoal: 1800,
            dailyWaterGoal: 2500,
            targetProtein: 120,
            targetCarbs: 180,
            targetFat: 60,
            activityLevel: .moderatelyActive,
            preferredLanguage: "en",
            notificationsEnabled: true,
            onboardingCompleted: true
        )
    }
}
