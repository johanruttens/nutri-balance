import Foundation
import CoreData

/// Maps between CDFoodEntry (Core Data) and FoodEntry (Domain) models.
enum FoodEntryMapper {

    /// Converts a Core Data food entry to a domain food entry
    static func toDomain(_ cdEntry: CDFoodEntry) -> FoodEntry {
        FoodEntry(
            id: cdEntry.id,
            date: cdEntry.date,
            mealCategory: MealCategory(rawValue: cdEntry.mealCategory) ?? .other,
            foodName: cdEntry.foodName,
            portionSize: cdEntry.portionSize,
            portionUnit: PortionUnit(rawValue: cdEntry.portionUnit) ?? .grams,
            calories: cdEntry.calories?.intValue,
            protein: cdEntry.protein?.doubleValue,
            carbs: cdEntry.carbs?.doubleValue,
            fat: cdEntry.fat?.doubleValue,
            fiber: cdEntry.fiber?.doubleValue,
            sugar: cdEntry.sugar?.doubleValue,
            notes: cdEntry.notes,
            hungerLevel: cdEntry.hungerLevel?.intValue,
            moodEmoji: cdEntry.moodEmoji,
            linkedFoodItemId: cdEntry.linkedFoodItem?.id,
            createdAt: cdEntry.createdAt,
            updatedAt: cdEntry.updatedAt
        )
    }

    /// Updates a Core Data food entry from a domain food entry
    static func toEntity(_ entry: FoodEntry, entity: CDFoodEntry) {
        entity.id = entry.id
        entity.date = entry.date
        entity.mealCategory = entry.mealCategory.rawValue
        entity.foodName = entry.foodName
        entity.portionSize = entry.portionSize
        entity.portionUnit = entry.portionUnit.rawValue
        entity.calories = entry.calories.map { NSNumber(value: $0) }
        entity.protein = entry.protein.map { NSNumber(value: $0) }
        entity.carbs = entry.carbs.map { NSNumber(value: $0) }
        entity.fat = entry.fat.map { NSNumber(value: $0) }
        entity.fiber = entry.fiber.map { NSNumber(value: $0) }
        entity.sugar = entry.sugar.map { NSNumber(value: $0) }
        entity.notes = entry.notes
        entity.hungerLevel = entry.hungerLevel.map { NSNumber(value: $0) }
        entity.moodEmoji = entry.moodEmoji
        entity.updatedAt = Date()
    }

    /// Creates a new Core Data food entry from a domain food entry
    static func createEntity(_ entry: FoodEntry, in context: NSManagedObjectContext) -> CDFoodEntry {
        let entity = CDFoodEntry(context: context)
        entity.createdAt = entry.createdAt
        toEntity(entry, entity: entity)
        return entity
    }
}
