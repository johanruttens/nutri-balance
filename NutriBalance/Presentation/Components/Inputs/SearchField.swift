import SwiftUI

/// Search input field with icon and clear button.
struct SearchField: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundColor(ColorPalette.textTertiary)

            TextField(placeholder, text: $text)
                .font(Typography.body)
                .foregroundColor(ColorPalette.textPrimary)
                .focused($isFocused)
                .onSubmit {
                    onSubmit?()
                }

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(ColorPalette.textTertiary)
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .frame(height: AppTheme.Size.inputHeight)
        .background(ColorPalette.inputBackground)
        .cornerRadius(AppTheme.CornerRadius.small)
    }
}

/// Number input field with stepper controls.
struct NumberInputField: View {
    let title: String
    @Binding var value: Double
    var unit: String = ""
    var step: Double = 1
    var range: ClosedRange<Double> = 0...1000
    var decimalPlaces: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(title)
                .font(Typography.caption1)
                .foregroundColor(ColorPalette.textSecondary)

            HStack(spacing: AppTheme.Spacing.md) {
                // Decrease button
                Button(action: decrease) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(ColorPalette.primary)
                        .frame(width: 36, height: 36)
                        .background(ColorPalette.primary.opacity(0.15))
                        .clipShape(Circle())
                }
                .disabled(value <= range.lowerBound)

                // Value display
                Text(formattedValue)
                    .font(Typography.numberMedium)
                    .foregroundColor(ColorPalette.textPrimary)
                    .frame(minWidth: 60)

                if !unit.isEmpty {
                    Text(unit)
                        .font(Typography.body)
                        .foregroundColor(ColorPalette.textSecondary)
                }

                // Increase button
                Button(action: increase) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(ColorPalette.primary)
                        .frame(width: 36, height: 36)
                        .background(ColorPalette.primary.opacity(0.15))
                        .clipShape(Circle())
                }
                .disabled(value >= range.upperBound)
            }
        }
    }

    private var formattedValue: String {
        String(format: "%.\(decimalPlaces)f", value)
    }

    private func increase() {
        value = min(range.upperBound, value + step)
    }

    private func decrease() {
        value = max(range.lowerBound, value - step)
    }
}

/// Portion size picker with common options.
struct PortionPicker: View {
    @Binding var size: Double
    @Binding var unit: PortionUnit
    var availableUnits: [PortionUnit] = PortionUnit.allCases

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Size input
            HStack {
                TextField("Amount", value: $size, format: .number.precision(.fractionLength(1)))
                    .font(Typography.numberMedium)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 80)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(ColorPalette.inputBackground)
                    .cornerRadius(AppTheme.CornerRadius.small)

                // Unit picker
                Menu {
                    ForEach(availableUnits) { unit in
                        Button(action: { self.unit = unit }) {
                            Text(unit.displayName)
                        }
                    }
                } label: {
                    HStack {
                        Text(unit.displayName)
                            .font(Typography.body)
                            .foregroundColor(ColorPalette.textPrimary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(ColorPalette.inputBackground)
                    .cornerRadius(AppTheme.CornerRadius.small)
                }
            }

            // Quick size buttons
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach([50.0, 100.0, 150.0, 200.0], id: \.self) { quickSize in
                    Button(action: { size = quickSize }) {
                        Text("\(Int(quickSize))")
                            .font(Typography.caption1)
                            .foregroundColor(size == quickSize ? .white : ColorPalette.textSecondary)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(size == quickSize ? ColorPalette.primary : ColorPalette.inputBackground)
                            .cornerRadius(AppTheme.CornerRadius.small)
                    }
                }
            }
        }
    }
}

/// Text input field with label.
struct LabeledTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var isRequired: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Text(label)
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)

                if isRequired {
                    Text("*")
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.error)
                }
            }

            TextField(placeholder, text: $text)
                .font(Typography.body)
                .padding(.horizontal, AppTheme.Spacing.md)
                .frame(height: AppTheme.Size.inputHeight)
                .background(ColorPalette.inputBackground)
                .cornerRadius(AppTheme.CornerRadius.small)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        SearchField(text: .constant(""), placeholder: "Search foods...")
        SearchField(text: .constant("Banana"), placeholder: "Search foods...")

        NumberInputField(
            title: "Calories",
            value: .constant(350),
            unit: "kcal",
            step: 10
        )

        NumberInputField(
            title: "Weight",
            value: .constant(83.5),
            unit: "kg",
            step: 0.1,
            range: 30...300,
            decimalPlaces: 1
        )

        PortionPicker(
            size: .constant(150),
            unit: .constant(.grams)
        )

        LabeledTextField(
            label: "Food Name",
            text: .constant(""),
            placeholder: "Enter food name",
            isRequired: true
        )
    }
    .padding()
}
