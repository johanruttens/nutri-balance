import Foundation
import CoreData

/// Centralized dependency injection container for the application.
/// Provides access to all repositories, use cases, and services.
@MainActor
final class DependencyContainer: ObservableObject {

    // MARK: - Singleton

    static let shared = DependencyContainer()

    // MARK: - Core Data

    private let persistenceController: PersistenceController

    var viewContext: NSManagedObjectContext {
        persistenceController.viewContext
    }

    // MARK: - Repositories

    private(set) lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(context: viewContext)
    }()

    private(set) lazy var foodEntryRepository: FoodEntryRepositoryProtocol = {
        FoodEntryRepository(context: viewContext)
    }()

    private(set) lazy var foodItemRepository: FoodItemRepositoryProtocol = {
        FoodItemRepository(context: viewContext)
    }()

    private(set) lazy var drinkEntryRepository: DrinkEntryRepositoryProtocol = {
        DrinkEntryRepository(context: viewContext)
    }()

    private(set) lazy var weightRepository: WeightRepositoryProtocol = {
        WeightRepository(context: viewContext)
    }()

    private(set) lazy var achievementRepository: AchievementRepositoryProtocol = {
        AchievementRepository(context: viewContext)
    }()

    // MARK: - Initialization

    private init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }

    // For testing
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }

    // MARK: - Use Case Factories

    // Onboarding
    func makeCreateUserUseCase() -> CreateUserUseCase {
        CreateUserUseCase(repository: userRepository)
    }

    func makeUpdateUserPreferencesUseCase() -> UpdateUserPreferencesUseCase {
        UpdateUserPreferencesUseCase(repository: userRepository)
    }

    // Food Tracking
    func makeAddFoodEntryUseCase() -> AddFoodEntryUseCase {
        AddFoodEntryUseCase(repository: foodEntryRepository)
    }

    func makeGetDailyEntriesUseCase() -> GetDailyEntriesUseCase {
        GetDailyEntriesUseCase(repository: foodEntryRepository)
    }

    func makeUpdateFoodEntryUseCase() -> UpdateFoodEntryUseCase {
        UpdateFoodEntryUseCase(repository: foodEntryRepository)
    }

    func makeDeleteFoodEntryUseCase() -> DeleteFoodEntryUseCase {
        DeleteFoodEntryUseCase(repository: foodEntryRepository)
    }

    // Favorites
    func makeAddToFavoritesUseCase() -> AddToFavoritesUseCase {
        AddToFavoritesUseCase(repository: foodItemRepository)
    }

    func makeGetFavoritesUseCase() -> GetFavoritesUseCase {
        GetFavoritesUseCase(repository: foodItemRepository)
    }

    func makeGetRecentFoodsUseCase() -> GetRecentFoodsUseCase {
        GetRecentFoodsUseCase(repository: foodItemRepository)
    }

    // Hydration
    func makeLogDrinkUseCase() -> LogDrinkUseCase {
        LogDrinkUseCase(repository: drinkEntryRepository)
    }

    func makeGetDailyHydrationUseCase() -> GetDailyHydrationUseCase {
        GetDailyHydrationUseCase(repository: drinkEntryRepository)
    }

    // Weight
    func makeLogWeightUseCase() -> LogWeightUseCase {
        LogWeightUseCase(repository: weightRepository)
    }

    func makeGetWeightHistoryUseCase() -> GetWeightHistoryUseCase {
        GetWeightHistoryUseCase(repository: weightRepository)
    }

    func makeCalculateProgressUseCase() -> CalculateProgressUseCase {
        CalculateProgressUseCase(
            weightRepository: weightRepository,
            userRepository: userRepository
        )
    }

    // Analytics
    func makeGetDailySummaryUseCase() -> GetDailySummaryUseCase {
        GetDailySummaryUseCase(
            foodEntryRepository: foodEntryRepository,
            drinkEntryRepository: drinkEntryRepository
        )
    }

    func makeGetWeeklySummaryUseCase() -> GetWeeklySummaryUseCase {
        GetWeeklySummaryUseCase(
            foodEntryRepository: foodEntryRepository,
            drinkEntryRepository: drinkEntryRepository,
            weightRepository: weightRepository
        )
    }

    func makeGetMonthlySummaryUseCase() -> GetMonthlySummaryUseCase {
        GetMonthlySummaryUseCase(
            foodEntryRepository: foodEntryRepository,
            drinkEntryRepository: drinkEntryRepository,
            weightRepository: weightRepository
        )
    }

    // Export
    func makeGeneratePDFReportUseCase() -> GeneratePDFReportUseCase {
        GeneratePDFReportUseCase(
            foodEntryRepository: foodEntryRepository,
            drinkEntryRepository: drinkEntryRepository,
            userRepository: userRepository,
            pdfGenerator: PDFGenerator()
        )
    }
}
