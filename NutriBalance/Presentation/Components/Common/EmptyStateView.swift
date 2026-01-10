import SwiftUI

/// Empty state view with icon, title, and optional action.
struct EmptyStateView: View {
    let icon: String
    let title: String
    var message: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(ColorPalette.textTertiary)

            VStack(spacing: AppTheme.Spacing.sm) {
                Text(title)
                    .font(Typography.headline)
                    .foregroundColor(ColorPalette.textPrimary)
                    .multilineTextAlignment(.center)

                if let message = message {
                    Text(message)
                        .font(Typography.body)
                        .foregroundColor(ColorPalette.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(AppTheme.Spacing.xl)
    }
}

/// Loading view with spinner.
struct LoadingView: View {
    var message: String? = nil

    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(ColorPalette.primary)

            if let message = message {
                Text(message)
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Error view with retry option.
struct ErrorView: View {
    let message: String
    var onRetry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(ColorPalette.warning)

            Text(message)
                .font(Typography.body)
                .foregroundColor(ColorPalette.textSecondary)
                .multilineTextAlignment(.center)

            if let onRetry = onRetry {
                SecondaryButton(title: "Retry", action: onRetry)
                    .frame(maxWidth: 200)
            }
        }
        .padding(AppTheme.Spacing.xl)
    }
}

/// Section header with optional action.
struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            Spacer()

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(Typography.callout)
                        .foregroundColor(ColorPalette.primary)
                }
            }
        }
    }
}

/// Divider with label.
struct LabeledDivider: View {
    let label: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Rectangle()
                .fill(ColorPalette.divider)
                .frame(height: 1)

            Text(label)
                .font(Typography.caption1)
                .foregroundColor(ColorPalette.textTertiary)

            Rectangle()
                .fill(ColorPalette.divider)
                .frame(height: 1)
        }
    }
}

/// Toast notification view.
struct ToastView: View {
    let message: String
    var type: ToastType = .info

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: type.icon)
                .font(.system(size: 16))
                .foregroundColor(.white)

            Text(message)
                .font(Typography.callout)
                .foregroundColor(.white)
        }
        .padding(.horizontal, AppTheme.Spacing.standard)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(type.color)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    enum ToastType {
        case success
        case error
        case info

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: return ColorPalette.success
            case .error: return ColorPalette.error
            case .info: return ColorPalette.primary
            }
        }
    }
}

/// Badge for counts/notifications.
struct BadgeView: View {
    let count: Int
    var color: Color = ColorPalette.error

    var body: some View {
        if count > 0 {
            Text(count > 99 ? "99+" : "\(count)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 32) {
            EmptyStateView(
                icon: "fork.knife.circle",
                title: "No meals logged yet",
                message: "Start tracking your nutrition by adding your first meal",
                actionTitle: "Add Food",
                action: {}
            )

            LoadingView(message: "Loading your data...")

            ErrorView(
                message: "Failed to load data. Please check your connection.",
                onRetry: {}
            )

            SectionHeader(title: "Recent Foods", actionTitle: "See All", action: {})

            LabeledDivider(label: "OR")

            VStack(spacing: 8) {
                ToastView(message: "Food added successfully!", type: .success)
                ToastView(message: "Failed to save", type: .error)
                ToastView(message: "Syncing data...", type: .info)
            }

            HStack(spacing: 20) {
                BadgeView(count: 3)
                BadgeView(count: 15, color: ColorPalette.primary)
                BadgeView(count: 150)
            }
        }
        .padding()
    }
}
