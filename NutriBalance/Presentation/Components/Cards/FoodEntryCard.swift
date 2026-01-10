import SwiftUI

/// Card displaying a single food entry.
struct FoodEntryCard: View {
    let entry: FoodEntry
    var onTap: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Meal category indicator
            Circle()
                .fill(entry.mealCategory.color)
                .frame(width: 8, height: 8)

            // Entry details
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(entry.foodName)
                    .font(Typography.bodyBold)
                    .foregroundColor(ColorPalette.textPrimary)
                    .lineLimit(1)

                Text(entry.portionString)
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)
            }

            Spacer()

            // Calories
            if let calories = entry.calories {
                Text("\(calories)")
                    .font(Typography.numberSmall)
                    .foregroundColor(ColorPalette.textPrimary)
                + Text(" kcal")
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)
            }

            // Delete button if provided
            if let onDelete = onDelete {
                IconButton(
                    systemName: "trash",
                    action: onDelete,
                    color: ColorPalette.error,
                    size: 16
                )
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

/// Swipeable food entry row for lists.
struct SwipeableFoodEntryRow: View {
    let entry: FoodEntry
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        FoodEntryCard(entry: entry, onTap: onEdit)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }

                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(ColorPalette.primary)
            }
    }
}

/// Compact food entry for suggestions/search results.
struct FoodSuggestionRow: View {
    let item: FoodItem
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Favorite indicator
                if item.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(Typography.body)
                        .foregroundColor(ColorPalette.textPrimary)
                        .lineLimit(1)

                    if let brand = item.brand {
                        Text(brand)
                            .font(Typography.caption1)
                            .foregroundColor(ColorPalette.textTertiary)
                    }
                }

                Spacer()

                // Default serving info
                VStack(alignment: .trailing, spacing: 2) {
                    if let calories = item.caloriesPer100 {
                        Text("\(Int(calories * item.defaultServingSize / 100)) kcal")
                            .font(Typography.caption1)
                            .foregroundColor(ColorPalette.textSecondary)
                    }

                    Text("\(Int(item.defaultServingSize)) \(item.defaultServingUnit.abbreviation)")
                        .font(Typography.caption2)
                        .foregroundColor(ColorPalette.textTertiary)
                }

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(ColorPalette.primary)
            }
            .padding(.vertical, AppTheme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        FoodEntryCard(entry: FoodEntry.mock)

        FoodEntryCard(
            entry: FoodEntry.mock,
            onTap: {},
            onDelete: {}
        )

        Divider()

        FoodSuggestionRow(item: FoodItem.mock, onSelect: {})
        FoodSuggestionRow(item: FoodItem.mockFavorites[0], onSelect: {})
    }
    .padding()
}
