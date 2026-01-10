import Foundation

/// Use case for getting daily summary.
struct GetDailySummaryUseCase {
    private let foodEntryRepository: FoodEntryRepositoryProtocol
    private let drinkEntryRepository: DrinkEntryRepositoryProtocol

    init(
        foodEntryRepository: FoodEntryRepositoryProtocol,
        drinkEntryRepository: DrinkEntryRepositoryProtocol
    ) {
        self.foodEntryRepository = foodEntryRepository
        self.drinkEntryRepository = drinkEntryRepository
    }

    func execute(for date: Date, user: User) async throws -> DailySummary {
        let foodEntries = try await foodEntryRepository.getEntries(for: date)
        let drinkEntries = try await drinkEntryRepository.getEntries(for: date)

        return DailySummary(
            date: date,
            foodEntries: foodEntries,
            drinkEntries: drinkEntries,
            calorieGoal: user.dailyCalorieGoal,
            waterGoal: user.dailyWaterGoal,
            proteinGoal: user.targetProtein,
            carbsGoal: user.targetCarbs,
            fatGoal: user.targetFat
        )
    }
}

/// Use case for getting weekly summary.
struct GetWeeklySummaryUseCase {
    private let foodEntryRepository: FoodEntryRepositoryProtocol
    private let drinkEntryRepository: DrinkEntryRepositoryProtocol
    private let weightRepository: WeightRepositoryProtocol

    init(
        foodEntryRepository: FoodEntryRepositoryProtocol,
        drinkEntryRepository: DrinkEntryRepositoryProtocol,
        weightRepository: WeightRepositoryProtocol
    ) {
        self.foodEntryRepository = foodEntryRepository
        self.drinkEntryRepository = drinkEntryRepository
        self.weightRepository = weightRepository
    }

    func execute(for date: Date, user: User) async throws -> WeeklySummary {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

        var dailySummaries: [DailySummary] = []

        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) else { continue }

            let foodEntries = try await foodEntryRepository.getEntries(for: day)
            let drinkEntries = try await drinkEntryRepository.getEntries(for: day)

            let summary = DailySummary(
                date: day,
                foodEntries: foodEntries,
                drinkEntries: drinkEntries,
                calorieGoal: user.dailyCalorieGoal,
                waterGoal: user.dailyWaterGoal,
                proteinGoal: user.targetProtein,
                carbsGoal: user.targetCarbs,
                fatGoal: user.targetFat
            )
            dailySummaries.append(summary)
        }

        return WeeklySummary(
            id: UUID(),
            startDate: startOfWeek,
            endDate: endOfWeek,
            dailySummaries: dailySummaries
        )
    }
}

/// Use case for getting monthly summary.
struct GetMonthlySummaryUseCase {
    private let foodEntryRepository: FoodEntryRepositoryProtocol
    private let drinkEntryRepository: DrinkEntryRepositoryProtocol
    private let weightRepository: WeightRepositoryProtocol

    init(
        foodEntryRepository: FoodEntryRepositoryProtocol,
        drinkEntryRepository: DrinkEntryRepositoryProtocol,
        weightRepository: WeightRepositoryProtocol
    ) {
        self.foodEntryRepository = foodEntryRepository
        self.drinkEntryRepository = drinkEntryRepository
        self.weightRepository = weightRepository
    }

    func execute(for date: Date, user: User) async throws -> [DailySummary] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        let range = calendar.range(of: .day, in: .month, for: date)!
        let endOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: startOfMonth)!

        let foodEntries = try await foodEntryRepository.getEntries(from: startOfMonth, to: endOfMonth)
        let drinkEntries = try await drinkEntryRepository.getEntries(from: startOfMonth, to: endOfMonth)

        // Group entries by day
        let groupedFood = Dictionary(grouping: foodEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        let groupedDrinks = Dictionary(grouping: drinkEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }

        var summaries: [DailySummary] = []

        for dayOffset in 0..<range.count {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: startOfMonth) else { continue }
            let startOfDay = calendar.startOfDay(for: day)

            let summary = DailySummary(
                date: day,
                foodEntries: groupedFood[startOfDay] ?? [],
                drinkEntries: groupedDrinks[startOfDay] ?? [],
                calorieGoal: user.dailyCalorieGoal,
                waterGoal: user.dailyWaterGoal,
                proteinGoal: user.targetProtein,
                carbsGoal: user.targetCarbs,
                fatGoal: user.targetFat
            )
            summaries.append(summary)
        }

        return summaries
    }
}
