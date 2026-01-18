import SwiftUI

/// Primary call-to-action button with teal background.
struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            HStack(spacing: AppTheme.Spacing.sm) {
                if isLoading {
                    SwiftUI.ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(Typography.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Size.buttonHeight)
            .background(isDisabled ? ColorPalette.divider : ColorPalette.primary)
            .cornerRadius(AppTheme.CornerRadius.medium)
        }
        .disabled(isDisabled || isLoading)
    }
}

/// Secondary button with outline style.
struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(Typography.headline)
            .foregroundColor(isDisabled ? ColorPalette.divider : ColorPalette.primary)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Size.buttonHeight)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(isDisabled ? ColorPalette.divider : ColorPalette.primary, lineWidth: 2)
            )
        }
        .disabled(isDisabled)
    }
}

/// Destructive button for delete actions.
struct DestructiveButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Typography.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppTheme.Size.buttonHeight)
                .background(ColorPalette.error)
                .cornerRadius(AppTheme.CornerRadius.medium)
        }
    }
}

/// Small icon button for inline actions.
struct IconButton: View {
    let systemName: String
    let action: () -> Void
    var color: Color = ColorPalette.primary
    var size: CGFloat = AppTheme.Size.iconMedium

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size))
                .foregroundColor(color)
                .frame(width: AppTheme.Size.minTouchTarget, height: AppTheme.Size.minTouchTarget)
        }
    }
}

/// Floating action button for primary actions.
struct FloatingActionButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(ColorPalette.primary)
                .clipShape(Circle())
                .shadow(
                    color: ColorPalette.primary.opacity(0.4),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
    }
}

/// Quick action button with icon and label.
struct QuickActionButton: View {
    let title: String
    let systemName: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: systemName)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 48, height: 48)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())

                Text(title)
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textPrimary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Continue", action: {})
        PrimaryButton(title: "Loading...", action: {}, isLoading: true)
        SecondaryButton(title: "Cancel", action: {})
        DestructiveButton(title: "Delete", action: {})

        HStack {
            IconButton(systemName: "plus", action: {})
            IconButton(systemName: "heart.fill", action: {}, color: .red)
            IconButton(systemName: "trash", action: {}, color: ColorPalette.error)
        }

        FloatingActionButton(systemName: "plus", action: {})

        HStack {
            QuickActionButton(title: "Food", systemName: "fork.knife", color: ColorPalette.lunch, action: {})
            QuickActionButton(title: "Water", systemName: "drop.fill", color: ColorPalette.water, action: {})
            QuickActionButton(title: "Weight", systemName: "scalemass", color: ColorPalette.primary, action: {})
        }
    }
    .padding()
}
