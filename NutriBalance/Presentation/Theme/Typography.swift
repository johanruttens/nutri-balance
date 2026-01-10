import SwiftUI

/// Application typography system using SF Pro (system default).
/// Provides consistent font styles throughout the app.
enum Typography {

    // MARK: - Large Titles

    /// Large title - 34pt Bold (Dashboard headers)
    static let largeTitle = Font.system(.largeTitle, design: .default, weight: .bold)

    // MARK: - Titles

    /// Title 1 - 28pt Bold
    static let title1 = Font.system(.title, design: .default, weight: .bold)

    /// Title 2 - 22pt Bold
    static let title2 = Font.system(.title2, design: .default, weight: .bold)

    /// Title 3 - 20pt Semibold
    static let title3 = Font.system(.title3, design: .default, weight: .semibold)

    // MARK: - Headlines

    /// Headline - 17pt Semibold (Section headers)
    static let headline = Font.system(.headline, design: .default, weight: .semibold)

    // MARK: - Body Text

    /// Body - 17pt Regular (Primary content)
    static let body = Font.system(.body, design: .default, weight: .regular)

    /// Body Bold - 17pt Semibold
    static let bodyBold = Font.system(.body, design: .default, weight: .semibold)

    // MARK: - Secondary Text

    /// Callout - 16pt Regular (Secondary content)
    static let callout = Font.system(.callout, design: .default, weight: .regular)

    /// Subheadline - 15pt Regular
    static let subheadline = Font.system(.subheadline, design: .default, weight: .regular)

    // MARK: - Small Text

    /// Footnote - 13pt Regular
    static let footnote = Font.system(.footnote, design: .default, weight: .regular)

    /// Caption 1 - 12pt Regular (Labels, metadata)
    static let caption1 = Font.system(.caption, design: .default, weight: .regular)

    /// Caption 2 - 11pt Regular
    static let caption2 = Font.system(.caption2, design: .default, weight: .regular)

    // MARK: - Numbers (Rounded Design)

    /// Large number - Title size, Rounded, Bold (Main calorie display)
    static let numberLarge = Font.system(.title, design: .rounded, weight: .bold)

    /// Medium number - Title 2 size, Rounded, Bold
    static let numberMedium = Font.system(.title2, design: .rounded, weight: .bold)

    /// Small number - Headline size, Rounded, Semibold
    static let numberSmall = Font.system(.headline, design: .rounded, weight: .semibold)

    /// Tiny number - Callout size, Rounded, Medium
    static let numberTiny = Font.system(.callout, design: .rounded, weight: .medium)
}

// MARK: - Text Style Modifiers

extension View {
    /// Apply primary text styling
    func textStylePrimary() -> some View {
        self
            .font(Typography.body)
            .foregroundColor(ColorPalette.textPrimary)
    }

    /// Apply secondary text styling
    func textStyleSecondary() -> some View {
        self
            .font(Typography.callout)
            .foregroundColor(ColorPalette.textSecondary)
    }

    /// Apply tertiary text styling
    func textStyleTertiary() -> some View {
        self
            .font(Typography.footnote)
            .foregroundColor(ColorPalette.textTertiary)
    }

    /// Apply headline styling
    func textStyleHeadline() -> some View {
        self
            .font(Typography.headline)
            .foregroundColor(ColorPalette.textPrimary)
    }

    /// Apply title styling
    func textStyleTitle() -> some View {
        self
            .font(Typography.title2)
            .foregroundColor(ColorPalette.textPrimary)
    }

    /// Apply large title styling
    func textStyleLargeTitle() -> some View {
        self
            .font(Typography.largeTitle)
            .foregroundColor(ColorPalette.textPrimary)
    }
}
