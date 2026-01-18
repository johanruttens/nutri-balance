import SwiftUI

/// Card displaying a meal category with entries summary.
struct MealCategoryCard: View {
    let category: MealCategory
    let entries: [FoodEntry]
    let onTap: () -> Void
    let onAdd: () -> Void

    private var totalCalories: Int {
        entries.compactMap { $0.calories }.reduce(0, +)
    }

    private var entryCount: Int {
        entries.count
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Category icon
                categoryIcon

                // Content
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text(category.displayName)
                        .font(Typography.headline)
                        .foregroundColor(ColorPalette.textPrimary)

                    if entries.isEmpty {
                        Text(L("ui.tapToAdd"))
                            .font(Typography.caption1)
                            .foregroundColor(ColorPalette.textTertiary)
                    } else {
                        Text("\(entryCount) item\(entryCount == 1 ? "" : "s") • \(totalCalories) kcal")
                            .font(Typography.caption1)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }

                Spacer()

                // Add button or chevron
                if entries.isEmpty {
                    IconButton(systemName: "plus.circle.fill", action: onAdd, color: category.color)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(ColorPalette.textTertiary)
                }
            }
            .padding(AppTheme.Spacing.standard)
            .background(ColorPalette.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
            .shadow(
                color: ColorPalette.shadow,
                radius: AppTheme.Shadow.card.radius,
                x: AppTheme.Shadow.card.x,
                y: AppTheme.Shadow.card.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var categoryIcon: some View {
        Image(systemName: category.iconName)
            .font(.system(size: 20))
            .foregroundColor(category.color)
            .frame(width: 44, height: 44)
            .background(category.color.opacity(0.15))
            .clipShape(Circle())
    }
}

/// Compact meal category indicator for dashboards.
struct MealCategoryIndicator: View {
    let category: MealCategory
    let isLogged: Bool

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Circle()
                .fill(isLogged ? category.color : ColorPalette.divider)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: isLogged ? "checkmark" : category.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isLogged ? .white : ColorPalette.textTertiary)
                )

            Text(category.displayName)
                .font(Typography.caption2)
                .foregroundColor(isLogged ? ColorPalette.textPrimary : ColorPalette.textTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 16) {
        MealCategoryCard(
            category: .breakfast,
            entries: [],
            onTap: {},
            onAdd: {}
        )

        MealCategoryCard(
            category: .lunch,
            entries: FoodEntry.mockBreakfast,
            onTap: {},
            onAdd: {}
        )

        HStack {
            ForEach(MealCategory.orderedForDisplay.prefix(4)) { category in
                MealCategoryIndicator(
                    category: category,
                    isLogged: [true, true, false, false][MealCategory.orderedForDisplay.firstIndex(of: category) ?? 0]
                )
            }
        }
    }
    .padding()
    .background(ColorPalette.backgroundSecondary)
}
