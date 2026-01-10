import Foundation
import SwiftUI

/// View model for adding food entries.
@MainActor
final class AddFoodViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var searchQuery = ""
    @Published var selectedCategory: MealCategory
    @Published var recentFoods: [FoodItem] = []
    @Published var favorites: [FoodItem] = []
    @Published var searchResults: [FoodItem] = []
    @Published var isSearching = false
    @Published var selectedFood: FoodItem?
    @Published var showCustomFood = false
    @Published var error: Error?

    // MARK: - Properties

    let container: DependencyContainer
    let date: Date

    // MARK: - Initialization

    init(container: DependencyContainer, mealCategory: MealCategory, date: Date) {
        self.container = container
        self.selectedCategory = mealCategory
        self.date = date
    }

    // MARK: - Public Methods

    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadRecentFoods() }
            group.addTask { await self.loadFavorites() }
        }
    }

    func search() async {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true

        do {
            let repository = container.makeFoodItemRepository()
            searchResults = try await repository.search(query: searchQuery)
        } catch {
            self.error = error
            searchResults = []
        }

        isSearching = false
    }

    func selectFood(_ food: FoodItem) {
        selectedFood = food
    }

    // MARK: - Private Methods

    private func loadRecentFoods() async {
        do {
            let useCase = container.makeGetRecentFoodsUseCase()
            recentFoods = try await useCase.execute(limit: 5)
        } catch {
            recentFoods = []
        }
    }

    private func loadFavorites() async {
        do {
            let useCase = container.makeGetFavoritesUseCase()
            favorites = try await useCase.execute()
        } catch {
            favorites = []
        }
    }
}
