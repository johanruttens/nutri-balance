import Foundation
import PDFKit

/// Use case for generating PDF reports.
struct GeneratePDFReportUseCase {
    private let foodEntryRepository: FoodEntryRepositoryProtocol
    private let drinkEntryRepository: DrinkEntryRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let pdfGenerator: PDFGenerator

    init(
        foodEntryRepository: FoodEntryRepositoryProtocol,
        drinkEntryRepository: DrinkEntryRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        pdfGenerator: PDFGenerator
    ) {
        self.foodEntryRepository = foodEntryRepository
        self.drinkEntryRepository = drinkEntryRepository
        self.userRepository = userRepository
        self.pdfGenerator = pdfGenerator
    }

    func execute(from startDate: Date, to endDate: Date) async throws -> Data {
        guard let user = try await userRepository.getCurrentUser() else {
            throw RepositoryError.notFound
        }

        let foodEntries = try await foodEntryRepository.getEntries(from: startDate, to: endDate)
        let drinkEntries = try await drinkEntryRepository.getEntries(from: startDate, to: endDate)

        let reportData = PDFReportData(
            user: user,
            startDate: startDate,
            endDate: endDate,
            foodEntries: foodEntries,
            drinkEntries: drinkEntries
        )

        return try pdfGenerator.generateReport(from: reportData)
    }
}

/// Data structure for PDF report generation.
struct PDFReportData {
    let user: User
    let startDate: Date
    let endDate: Date
    let foodEntries: [FoodEntry]
    let drinkEntries: [DrinkEntry]

    var totalCalories: Int {
        foodEntries.compactMap { $0.calories }.reduce(0, +)
    }

    var totalProtein: Double {
        foodEntries.compactMap { $0.protein }.reduce(0, +)
    }

    var totalCarbs: Double {
        foodEntries.compactMap { $0.carbs }.reduce(0, +)
    }

    var totalFat: Double {
        foodEntries.compactMap { $0.fat }.reduce(0, +)
    }

    var totalWaterIntake: Double {
        drinkEntries.reduce(0) { $0 + $1.effectiveHydration }
    }

    var entriesByDate: [Date: [FoodEntry]] {
        Dictionary(grouping: foodEntries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
    }
}
