import SwiftUI

/// Main achievements view displaying unlocked and locked achievements.
struct AchievementsView: View {
    @StateObject private var viewModel: AchievementsViewModel
    @State private var selectedAchievement: Achievement?

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: AchievementsViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Stats header
                    AchievementStatsHeader(
                        unlocked: viewModel.unlockedCount,
                        total: viewModel.totalCount
                    )

                    // Unlocked achievements
                    if !viewModel.unlockedAchievements.isEmpty {
                        AchievementSection(
                            title: L("achievements.unlocked"),
                            achievements: viewModel.unlockedAchievements,
                            onTap: { selectedAchievement = $0 }
                        )
                    }

                    // In progress achievements
                    if !viewModel.inProgressAchievements.isEmpty {
                        AchievementSection(
                            title: L("achievements.inProgress"),
                            achievements: viewModel.inProgressAchievements,
                            onTap: { selectedAchievement = $0 }
                        )
                    }

                    // Locked achievements
                    if !viewModel.lockedAchievements.isEmpty {
                        AchievementSection(
                            title: L("achievements.locked"),
                            achievements: viewModel.lockedAchievements,
                            onTap: { selectedAchievement = $0 }
                        )
                    }
                }
                .padding(AppTheme.Spacing.standard)
            }
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(L("achievements.title"))
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.loadAchievements()
            }
            .task {
                await viewModel.loadAchievements()
            }
            .sheet(item: $selectedAchievement) { achievement in
                AchievementDetailView(achievement: achievement)
            }
        }
    }
}

/// Achievement stats header.
struct AchievementStatsHeader: View {
    let unlocked: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(unlocked) / Double(total)
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Trophy icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 80, height: 80)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            // Count
            Text("\(unlocked) / \(total)")
                .font(Typography.numberLarge)
                .foregroundColor(ColorPalette.textPrimary)

            Text(L("achievements.unlocked"))
                .font(Typography.caption1)
                .foregroundColor(ColorPalette.textSecondary)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorPalette.divider)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, AppTheme.Spacing.xl)
        }
        .padding(AppTheme.Spacing.lg)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.large)
    }
}

/// Achievement section with grid.
struct AchievementSection: View {
    let title: String
    let achievements: [Achievement]
    let onTap: (Achievement) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(title)
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.md) {
                ForEach(achievements) { achievement in
                    AchievementCard(achievement: achievement)
                        .onTapGesture { onTap(achievement) }
                }
            }
        }
    }
}

/// Single achievement card.
struct AchievementCard: View {
    let achievement: Achievement

    private var isUnlocked: Bool {
        achievement.unlockedAt != nil
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievement.type.color.opacity(0.2) : ColorPalette.divider)
                    .frame(width: 60, height: 60)

                Image(systemName: achievement.type.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(isUnlocked ? achievement.type.color : ColorPalette.textTertiary)

                // Lock overlay
                if !isUnlocked {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 60, height: 60)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }

            // Name
            Text(achievement.type.displayName)
                .font(Typography.caption1)
                .foregroundColor(isUnlocked ? ColorPalette.textPrimary : ColorPalette.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Progress (if in progress)
            if !isUnlocked && achievement.progress > 0 {
                ProgressView(value: achievement.progress)
                    .tint(achievement.type.color)
                    .frame(width: 50)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppTheme.Spacing.md)
        .background(ColorPalette.cardBackground)
        .cornerRadius(AppTheme.CornerRadius.medium)
    }
}

/// Achievement detail view.
struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss

    private var isUnlocked: Bool {
        achievement.unlockedAt != nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()

                // Icon with animation
                ZStack {
                    // Background circles
                    if isUnlocked {
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(achievement.type.color.opacity(0.2 - Double(i) * 0.05), lineWidth: 2)
                                .frame(width: CGFloat(120 + i * 30), height: CGFloat(120 + i * 30))
                        }
                    }

                    Circle()
                        .fill(isUnlocked ?
                            LinearGradient(
                                colors: [achievement.type.color, achievement.type.color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            ) :
                            LinearGradient(
                                colors: [ColorPalette.divider, ColorPalette.divider],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 100, height: 100)

                    Image(systemName: achievement.type.iconName)
                        .font(.system(size: 44))
                        .foregroundColor(isUnlocked ? .white : ColorPalette.textTertiary)
                }

                // Title and description
                VStack(spacing: AppTheme.Spacing.md) {
                    Text(achievement.type.displayName)
                        .font(Typography.title2)
                        .foregroundColor(ColorPalette.textPrimary)

                    Text(achievement.type.description)
                        .font(Typography.body)
                        .foregroundColor(ColorPalette.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Category badge
                    Text(achievement.type.category.rawValue.capitalized)
                        .font(Typography.caption1)
                        .foregroundColor(achievement.type.color)
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.xs)
                        .background(achievement.type.color.opacity(0.15))
                        .cornerRadius(AppTheme.CornerRadius.small)
                }

                // Unlock date or progress
                if let unlockedAt = achievement.unlockedAt {
                    VStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(ColorPalette.success)

                        Text(L("achievements.unlockedOn"))
                            .font(Typography.caption1)
                            .foregroundColor(ColorPalette.textSecondary)

                        Text(LDate(unlockedAt, style: .medium))
                            .font(Typography.callout)
                            .foregroundColor(ColorPalette.textPrimary)
                    }
                } else if achievement.progress > 0 {
                    VStack(spacing: AppTheme.Spacing.sm) {
                        Text("\(Int(achievement.progress * 100))%")
                            .font(Typography.numberMedium)
                            .foregroundColor(ColorPalette.textPrimary)

                        ProgressView(value: achievement.progress)
                            .tint(achievement.type.color)
                            .frame(width: 150)

                        Text(L("achievements.keepGoing"))
                            .font(Typography.caption1)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                } else {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Image(systemName: "lock.fill")
                        Text(L("achievements.notYetUnlocked"))
                    }
                    .font(Typography.callout)
                    .foregroundColor(ColorPalette.textTertiary)
                }

                Spacer()
            }
            .padding(AppTheme.Spacing.standard)
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(L("achievements.details"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("common.done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AchievementsView(container: DependencyContainer.preview)
}
