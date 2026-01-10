import Foundation
import CoreData

/// Maps between CDDrinkEntry (Core Data) and DrinkEntry (Domain) models.
enum DrinkEntryMapper {

    /// Converts a Core Data drink entry to a domain drink entry
    static func toDomain(_ cdEntry: CDDrinkEntry) -> DrinkEntry {
        DrinkEntry(
            id: cdEntry.id,
            date: cdEntry.date,
            drinkType: DrinkType(rawValue: cdEntry.drinkType) ?? .other,
            name: cdEntry.name,
            amount: cdEntry.amount,
            calories: cdEntry.calories?.intValue,
            caffeineContent: cdEntry.caffeineContent?.doubleValue,
            sugarContent: cdEntry.sugarContent?.doubleValue,
            notes: cdEntry.notes,
            createdAt: cdEntry.createdAt,
            updatedAt: cdEntry.updatedAt
        )
    }

    /// Updates a Core Data drink entry from a domain drink entry
    static func toEntity(_ entry: DrinkEntry, entity: CDDrinkEntry) {
        entity.id = entry.id
        entity.date = entry.date
        entity.drinkType = entry.drinkType.rawValue
        entity.name = entry.name
        entity.amount = entry.amount
        entity.calories = entry.calories.map { NSNumber(value: $0) }
        entity.caffeineContent = entry.caffeineContent.map { NSNumber(value: $0) }
        entity.sugarContent = entry.sugarContent.map { NSNumber(value: $0) }
        entity.notes = entry.notes
        entity.updatedAt = Date()
    }

    /// Creates a new Core Data drink entry from a domain drink entry
    static func createEntity(_ entry: DrinkEntry, in context: NSManagedObjectContext) -> CDDrinkEntry {
        let entity = CDDrinkEntry(context: context)
        entity.createdAt = entry.createdAt
        toEntity(entry, entity: entity)
        return entity
    }
}
