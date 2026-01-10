import Foundation
import CoreData

/// Maps between CDWeightEntry (Core Data) and WeightEntry (Domain) models.
enum WeightEntryMapper {

    /// Converts a Core Data weight entry to a domain weight entry
    static func toDomain(_ cdEntry: CDWeightEntry) -> WeightEntry {
        WeightEntry(
            id: cdEntry.id,
            date: cdEntry.date,
            weight: cdEntry.weight,
            notes: cdEntry.notes,
            bodyFatPercentage: cdEntry.bodyFatPercentage?.doubleValue,
            muscleMass: cdEntry.muscleMass?.doubleValue,
            waistCircumference: cdEntry.waistCircumference?.doubleValue,
            hipCircumference: cdEntry.hipCircumference?.doubleValue,
            createdAt: cdEntry.createdAt
        )
    }

    /// Updates a Core Data weight entry from a domain weight entry
    static func toEntity(_ entry: WeightEntry, entity: CDWeightEntry) {
        entity.id = entry.id
        entity.date = entry.date
        entity.weight = entry.weight
        entity.notes = entry.notes
        entity.bodyFatPercentage = entry.bodyFatPercentage.map { NSNumber(value: $0) }
        entity.muscleMass = entry.muscleMass.map { NSNumber(value: $0) }
        entity.waistCircumference = entry.waistCircumference.map { NSNumber(value: $0) }
        entity.hipCircumference = entry.hipCircumference.map { NSNumber(value: $0) }
    }

    /// Creates a new Core Data weight entry from a domain weight entry
    static func createEntity(_ entry: WeightEntry, in context: NSManagedObjectContext) -> CDWeightEntry {
        let entity = CDWeightEntry(context: context)
        entity.createdAt = entry.createdAt
        toEntity(entry, entity: entity)
        return entity
    }
}
