import SwiftUI

// Import L() function from LocalizationManager

/// Container view for the onboarding flow.
struct OnboardingContainerView: View {
    let container: DependencyContainer
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: OnboardingViewModel

    init(container: DependencyContainer) {
        self.container = container
        _viewModel = StateObject(wrappedValue: OnboardingViewModel(container: container))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            OnboardingProgressBar(currentStep: viewModel.currentStep, totalSteps: viewModel.totalSteps)
                .padding(.horizontal, AppTheme.Spacing.standard)
                .padding(.top, AppTheme.Spacing.md)

            // Content
            TabView(selection: $viewModel.currentStep) {
                WelcomeStepView(viewModel: viewModel)
                    .tag(0)

                NameStepView(viewModel: viewModel)
                    .tag(1)

                GoalsStepView(viewModel: viewModel)
                    .tag(2)

                PreferencesStepView(viewModel: viewModel)
                    .tag(3)

                CompleteStepView(viewModel: viewModel, onComplete: completeOnboarding)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: viewModel.currentStep)
        }
        .background(ColorPalette.background)
    }

    private func completeOnboarding() {
        Task {
            await viewModel.saveUser()
            appState.completeOnboarding()
        }
    }
}

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? ColorPalette.primary : ColorPalette.divider)
                    .frame(height: 4)
            }
        }
    }
}

// MARK: - Welcome Step

struct WelcomeStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            // Logo/Icon
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(ColorPalette.primary)

            VStack(spacing: AppTheme.Spacing.md) {
                Text(L("onboarding.welcome.title"))
                    .font(Typography.largeTitle)
                    .foregroundColor(ColorPalette.textPrimary)
                    .multilineTextAlignment(.center)

                Text(L("onboarding.welcome.subtitle"))
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Language selector
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(L("settings.language"))
                    .font(Typography.caption1)
                    .foregroundColor(ColorPalette.textSecondary)

                Picker(selection: $viewModel.selectedLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AppTheme.Spacing.xl)
                .onChange(of: viewModel.selectedLanguage) { newLanguage in
                    LocalizationManager.shared.setLanguage(newLanguage)
                }
            }

            Spacer()

            Button(action: { viewModel.nextStep() }) {
                Text(L("onboarding.welcome.getStarted"))
                    .font(Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppTheme.Size.buttonHeight)
                    .background(ColorPalette.primary)
                    .cornerRadius(AppTheme.CornerRadius.medium)
            }
            .padding(.horizontal, AppTheme.Spacing.standard)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
    }
}

// MARK: - Name Step

struct NameStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isFirstNameFocused: Bool
    @State private var showValidationError = false

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            VStack(spacing: AppTheme.Spacing.md) {
                Text(L("onboarding.name.title"))
                    .font(Typography.title1)
                    .foregroundColor(ColorPalette.textPrimary)

                VStack(spacing: AppTheme.Spacing.md) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                        TextField(L("onboarding.name.placeholder"), text: $viewModel.firstName)
                            .textFieldStyle(NutriTextFieldStyle())
                            .focused($isFirstNameFocused)
                            .onChange(of: viewModel.firstName) { _ in
                                if showValidationError && !viewModel.firstName.isEmpty {
                                    showValidationError = false
                                }
                            }

                        if showValidationError && viewModel.firstName.isEmpty {
                            Text(L("validation.nameRequired"))
                                .font(Typography.caption2)
                                .foregroundColor(ColorPalette.error)
                        }
                    }

                    TextField(L("onboarding.name.lastName"), text: $viewModel.lastName)
                        .textFieldStyle(NutriTextFieldStyle())
                }
                .padding(.horizontal, AppTheme.Spacing.standard)
            }

            Spacer()

            HStack(spacing: AppTheme.Spacing.md) {
                Button(action: { viewModel.previousStep() }) {
                    Text(L("common.back"))
                        .font(Typography.headline)
                        .foregroundColor(ColorPalette.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Size.buttonHeight)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .stroke(ColorPalette.primary, lineWidth: 2)
                        )
                }

                Button(action: {
                    if viewModel.firstName.isEmpty {
                        showValidationError = true
                        HapticManager.shared.error()
                    } else {
                        viewModel.nextStep()
                    }
                }) {
                    Text(L("common.next"))
                        .font(Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Size.buttonHeight)
                        .background(viewModel.firstName.isEmpty ? ColorPalette.divider : ColorPalette.primary)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.standard)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
        .onAppear { isFirstNameFocused = true }
    }
}

// MARK: - Goals Step

struct GoalsStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Text(L("onboarding.goals.title"))
                .font(Typography.title1)
                .foregroundColor(ColorPalette.textPrimary)
                .padding(.top, AppTheme.Spacing.xl)

            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    // Current Weight
                    GoalInputRow(
                        title: L("onboarding.goals.currentWeight"),
                        value: $viewModel.currentWeight,
                        unit: "kg"
                    )

                    // Target Weight
                    GoalInputRow(
                        title: L("onboarding.goals.targetWeight"),
                        value: $viewModel.targetWeight,
                        unit: "kg"
                    )

                    // Activity Level
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text(L("onboarding.goals.activityLevel"))
                            .font(Typography.headline)
                            .foregroundColor(ColorPalette.textPrimary)

                        Picker("Activity Level", selection: $viewModel.activityLevel) {
                            ForEach(ActivityLevel.allCases) { level in
                                Text(level.displayName).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, AppTheme.Spacing.standard)
                }
            }

            HStack(spacing: AppTheme.Spacing.md) {
                Button(action: { viewModel.previousStep() }) {
                    Text(L("common.back"))
                        .font(Typography.headline)
                        .foregroundColor(ColorPalette.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Size.buttonHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .stroke(ColorPalette.primary, lineWidth: 2)
                        )
                }

                Button(action: { viewModel.nextStep() }) {
                    Text(L("common.next"))
                        .font(Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Size.buttonHeight)
                        .background(ColorPalette.primary)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.standard)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
    }
}

struct GoalInputRow: View {
    let title: String
    @Binding var value: Double
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(title)
                .font(Typography.headline)
                .foregroundColor(ColorPalette.textPrimary)

            HStack {
                TextField("0", value: $value, format: .number.precision(.fractionLength(1)))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(NutriTextFieldStyle())

                Text(unit)
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textSecondary)
                    .frame(width: 30)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.standard)
    }
}

// MARK: - Preferences Step

struct PreferencesStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Text(L("onboarding.preferences.title"))
                .font(Typography.title1)
                .foregroundColor(ColorPalette.textPrimary)
                .padding(.top, AppTheme.Spacing.xl)

            VStack(spacing: AppTheme.Spacing.lg) {
                // Language selection
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text(L("settings.language"))
                        .font(Typography.headline)
                        .foregroundColor(ColorPalette.textPrimary)

                    Picker(selection: $viewModel.selectedLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.selectedLanguage) { newLanguage in
                        LocalizationManager.shared.setLanguage(newLanguage)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.standard)

                Toggle(isOn: $viewModel.notificationsEnabled) {
                    Text(L("onboarding.preferences.notifications"))
                        .font(Typography.body)
                        .foregroundColor(ColorPalette.textPrimary)
                }
                .tint(ColorPalette.primary)
                .padding(.horizontal, AppTheme.Spacing.standard)
            }

            Spacer()

            HStack(spacing: AppTheme.Spacing.md) {
                Button(action: { viewModel.previousStep() }) {
                    Text(L("common.back"))
                        .font(Typography.headline)
                        .foregroundColor(ColorPalette.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Size.buttonHeight)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                                .stroke(ColorPalette.primary, lineWidth: 2)
                        )
                }

                Button(action: { viewModel.nextStep() }) {
                    Text(L("common.next"))
                        .font(Typography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppTheme.Size.buttonHeight)
                        .background(ColorPalette.primary)
                        .cornerRadius(AppTheme.CornerRadius.medium)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.standard)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
    }
}

// MARK: - Complete Step

struct CompleteStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(ColorPalette.success)

            VStack(spacing: AppTheme.Spacing.md) {
                Text(L("onboarding.complete.title"))
                    .font(Typography.largeTitle)
                    .foregroundColor(ColorPalette.textPrimary)

                Text(L("onboarding.complete.subtitle"))
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textSecondary)
            }

            Spacer()

            Button(action: onComplete) {
                Text(L("onboarding.complete.start"))
                    .font(Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppTheme.Size.buttonHeight)
                    .background(ColorPalette.primary)
                    .cornerRadius(AppTheme.CornerRadius.medium)
            }
            .padding(.horizontal, AppTheme.Spacing.standard)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
    }
}

// MARK: - Custom Text Field Style

struct NutriTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(Typography.body)
            .padding(.horizontal, AppTheme.Spacing.standard)
            .frame(height: AppTheme.Size.inputHeight)
            .background(ColorPalette.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.small)
    }
}

#Preview {
    OnboardingContainerView(container: DependencyContainer.preview)
        .environmentObject(AppState())
}
