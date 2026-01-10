import SwiftUI

/// Centralized theme configuration for the application.
/// Provides consistent spacing, sizing, and styling values.
enum AppTheme {

    // MARK: - Spacing

    enum Spacing {
        /// Extra small spacing - 4pt
        static let xs: CGFloat = 4

        /// Small spacing - 8pt
        static let sm: CGFloat = 8

        /// Medium spacing - 12pt
        static let md: CGFloat = 12

        /// Standard spacing - 16pt
        static let standard: CGFloat = 16

        /// Large spacing - 24pt
        static let lg: CGFloat = 24

        /// Extra large spacing - 32pt
        static let xl: CGFloat = 32

        /// Double extra large spacing - 48pt
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        /// Small corner radius - 8pt (Input fields)
        static let small: CGFloat = 8

        /// Medium corner radius - 12pt (Buttons)
        static let medium: CGFloat = 12

        /// Large corner radius - 16pt (Cards)
        static let large: CGFloat = 16

        /// Extra large corner radius - 24pt (Modals)
        static let extraLarge: CGFloat = 24

        /// Full corner radius (for circular elements)
        static let full: CGFloat = .infinity
    }

    // MARK: - Component Sizes

    enum Size {
        /// Minimum touch target size (44x44pt per Apple HIG)
        static let minTouchTarget: CGFloat = 44

        /// Standard button height - 48pt
        static let buttonHeight: CGFloat = 48

        /// Small button height - 36pt
        static let buttonHeightSmall: CGFloat = 36

        /// Large button height - 56pt
        static let buttonHeightLarge: CGFloat = 56

        /// Input field height - 48pt
        static let inputHeight: CGFloat = 48

        /// Icon size small - 20pt
        static let iconSmall: CGFloat = 20

        /// Icon size medium - 24pt
        static let iconMedium: CGFloat = 24

        /// Icon size large - 32pt
        static let iconLarge: CGFloat = 32

        /// Avatar size small - 40pt
        static let avatarSmall: CGFloat = 40

        /// Avatar size medium - 64pt
        static let avatarMedium: CGFloat = 64

        /// Avatar size large - 100pt
        static let avatarLarge: CGFloat = 100

        /// Progress ring size - 120pt
        static let progressRing: CGFloat = 120

        /// Tab bar icon size - 24pt
        static let tabBarIcon: CGFloat = 24
    }

    // MARK: - Shadows

    enum Shadow {
        /// Card shadow
        static let card = ShadowStyle(
            color: ColorPalette.shadow,
            radius: 8,
            x: 0,
            y: 2
        )

        /// Elevated shadow (for floating elements)
        static let elevated = ShadowStyle(
            color: ColorPalette.shadow,
            radius: 16,
            x: 0,
            y: 4
        )

        /// Subtle shadow
        static let subtle = ShadowStyle(
            color: ColorPalette.shadow,
            radius: 4,
            x: 0,
            y: 1
        )
    }

    // MARK: - Animation

    enum Animation {
        /// Standard animation duration
        static let standard: Double = 0.3

        /// Fast animation duration
        static let fast: Double = 0.15

        /// Slow animation duration
        static let slow: Double = 0.5

        /// Spring animation
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)

        /// Bounce animation
        static let bounce = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
}

// MARK: - Shadow Style

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions for Theming

extension View {
    /// Apply card styling with shadow
    func cardStyle() -> some View {
        self
            .background(ColorPalette.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
            .shadow(
                color: AppTheme.Shadow.card.color,
                radius: AppTheme.Shadow.card.radius,
                x: AppTheme.Shadow.card.x,
                y: AppTheme.Shadow.card.y
            )
    }

    /// Apply elevated styling with larger shadow
    func elevatedStyle() -> some View {
        self
            .background(ColorPalette.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.large)
            .shadow(
                color: AppTheme.Shadow.elevated.color,
                radius: AppTheme.Shadow.elevated.radius,
                x: AppTheme.Shadow.elevated.x,
                y: AppTheme.Shadow.elevated.y
            )
    }

    /// Apply input field styling
    func inputFieldStyle() -> some View {
        self
            .padding(.horizontal, AppTheme.Spacing.standard)
            .frame(height: AppTheme.Size.inputHeight)
            .background(ColorPalette.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.small)
    }

    /// Ensure minimum touch target size
    func minTouchTarget() -> some View {
        self
            .frame(minWidth: AppTheme.Size.minTouchTarget, minHeight: AppTheme.Size.minTouchTarget)
    }
}
