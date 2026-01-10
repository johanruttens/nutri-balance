import SwiftUI

/// Main settings view.
struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showEditProfile = false
    @State private var showEditGoals = false
    @State private var showPrivacyPolicy = false
    @State private var showAbout = false

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(container: container))
    }

    var body: some View {
        NavigationStack {
            List {
                // Profile section
                Section {
                    ProfileRow(user: viewModel.user)
                        .onTapGesture { showEditProfile = true }
                } header: {
                    Text(String(localized: "settings.profile"))
                }

                // Goals section
                Section {
                    SettingsRow(
                        icon: "target",
                        title: String(localized: "settings.nutritionGoals"),
                        value: "\(viewModel.user?.dailyCalorieGoal ?? 0) kcal"
                    )
                    .onTapGesture { showEditGoals = true }

                    SettingsRow(
                        icon: "scalemass",
                        title: String(localized: "settings.weightGoal"),
                        value: "\(String(format: "%.1f", viewModel.user?.targetWeight ?? 0)) kg"
                    )
                    .onTapGesture { showEditGoals = true }
                } header: {
                    Text(String(localized: "settings.goals"))
                }

                // Preferences section
                Section {
                    Toggle(isOn: $viewModel.notificationsEnabled) {
                        SettingsLabel(icon: "bell.fill", title: String(localized: "settings.notifications"))
                    }
                    .onChange(of: viewModel.notificationsEnabled) { _, newValue in
                        Task { await viewModel.updateNotifications(enabled: newValue) }
                    }

                    Picker(selection: $viewModel.selectedLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    } label: {
                        SettingsLabel(icon: "globe", title: String(localized: "settings.language"))
                    }
                } header: {
                    Text(String(localized: "settings.preferences"))
                }

                // Data section
                Section {
                    Button(action: { viewModel.exportData() }) {
                        SettingsLabel(icon: "square.and.arrow.up", title: String(localized: "settings.exportData"))
                    }

                    Button(role: .destructive, action: { viewModel.showDeleteConfirmation = true }) {
                        SettingsLabel(
                            icon: "trash",
                            title: String(localized: "settings.deleteData"),
                            color: ColorPalette.error
                        )
                    }
                } header: {
                    Text(String(localized: "settings.data"))
                }

                // About section
                Section {
                    Button(action: { showPrivacyPolicy = true }) {
                        SettingsLabel(icon: "hand.raised.fill", title: String(localized: "settings.privacyPolicy"))
                    }

                    Button(action: { showAbout = true }) {
                        SettingsLabel(icon: "info.circle", title: String(localized: "settings.about"))
                    }

                    SettingsRow(
                        icon: "number",
                        title: String(localized: "settings.version"),
                        value: viewModel.appVersion
                    )
                } header: {
                    Text(String(localized: "settings.about"))
                }
            }
            .navigationTitle(String(localized: "settings.title"))
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadUser()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(container: viewModel.container) {
                    Task { await viewModel.loadUser() }
                }
            }
            .sheet(isPresented: $showEditGoals) {
                EditGoalsView(container: viewModel.container) {
                    Task { await viewModel.loadUser() }
                }
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .alert(String(localized: "settings.deleteConfirmTitle"), isPresented: $viewModel.showDeleteConfirmation) {
                Button(String(localized: "common.cancel"), role: .cancel) {}
                Button(String(localized: "common.delete"), role: .destructive) {
                    Task { await viewModel.deleteAllData() }
                }
            } message: {
                Text(String(localized: "settings.deleteConfirmMessage"))
            }
        }
    }
}

/// App language options.
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case dutch = "nl"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .dutch: return "Nederlands"
        }
    }
}

/// Profile row in settings.
struct ProfileRow: View {
    let user: User?

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(ColorPalette.primary.opacity(0.15))
                    .frame(width: 60, height: 60)

                Text(user?.firstName.prefix(1).uppercased() ?? "?")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(ColorPalette.primary)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(user?.displayName ?? String(localized: "settings.noName"))
                    .font(Typography.headline)
                    .foregroundColor(ColorPalette.textPrimary)

                if let email = user?.email {
                    Text(email)
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(ColorPalette.textTertiary)
        }
        .padding(.vertical, AppTheme.Spacing.sm)
    }
}

/// Generic settings row.
struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            SettingsLabel(icon: icon, title: title)

            Spacer()

            Text(value)
                .font(Typography.body)
                .foregroundColor(ColorPalette.textSecondary)

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(ColorPalette.textTertiary)
        }
    }
}

/// Settings label with icon.
struct SettingsLabel: View {
    let icon: String
    let title: String
    var color: Color = ColorPalette.primary

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(title)
                .font(Typography.body)
                .foregroundColor(color == ColorPalette.primary ? ColorPalette.textPrimary : color)
        }
    }
}

/// Edit profile view.
struct EditProfileView: View {
    let container: DependencyContainer
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var height: Double = 175
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledTextField(
                        label: String(localized: "profile.name"),
                        text: $name,
                        placeholder: String(localized: "profile.namePlaceholder"),
                        isRequired: true
                    )

                    LabeledTextField(
                        label: String(localized: "profile.email"),
                        text: $email,
                        placeholder: String(localized: "profile.emailPlaceholder")
                    )
                }

                Section {
                    NumberInputField(
                        title: String(localized: "profile.height"),
                        value: $height,
                        unit: "cm",
                        step: 1,
                        range: 100...250
                    )
                }
            }
            .navigationTitle(String(localized: "profile.edit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.save")) {
                        saveProfile()
                    }
                    .disabled(name.isEmpty || isSaving)
                }
            }
            .task {
                await loadProfile()
            }
        }
    }

    private func loadProfile() async {
        let repository = container.makeUserRepository()
        if let user = try? await repository.getUser() {
            name = user.firstName
            email = user.email ?? ""
            height = user.height ?? 175
        }
    }

    private func saveProfile() {
        isSaving = true

        Task {
            let useCase = container.makeUpdateUserPreferencesUseCase()
            try? await useCase.execute(
                firstName: name,
                email: email.isEmpty ? nil : email,
                height: height
            )

            isSaving = false
            onSave()
            dismiss()
        }
    }
}

/// Edit goals view.
struct EditGoalsView: View {
    let container: DependencyContainer
    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var targetCalories: Double = 1800
    @State private var targetProtein: Double = 100
    @State private var targetCarbs: Double = 200
    @State private var targetFat: Double = 60
    @State private var targetWeight: Double = 80
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "goals.nutrition")) {
                    NumberInputField(
                        title: String(localized: "goals.calories"),
                        value: $targetCalories,
                        unit: "kcal",
                        step: 50,
                        range: 1000...5000
                    )

                    NumberInputField(
                        title: String(localized: "goals.protein"),
                        value: $targetProtein,
                        unit: "g",
                        step: 5,
                        range: 30...300
                    )

                    NumberInputField(
                        title: String(localized: "goals.carbs"),
                        value: $targetCarbs,
                        unit: "g",
                        step: 10,
                        range: 50...500
                    )

                    NumberInputField(
                        title: String(localized: "goals.fat"),
                        value: $targetFat,
                        unit: "g",
                        step: 5,
                        range: 20...200
                    )
                }

                Section(String(localized: "goals.weight")) {
                    NumberInputField(
                        title: String(localized: "goals.targetWeight"),
                        value: $targetWeight,
                        unit: "kg",
                        step: 0.5,
                        range: 30...300,
                        decimalPlaces: 1
                    )
                }
            }
            .navigationTitle(String(localized: "goals.edit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.save")) {
                        saveGoals()
                    }
                    .disabled(isSaving)
                }
            }
            .task {
                await loadGoals()
            }
        }
    }

    private func loadGoals() async {
        let repository = container.makeUserRepository()
        if let user = try? await repository.getUser() {
            targetCalories = Double(user.dailyCalorieGoal)
            targetProtein = user.targetProtein
            targetCarbs = user.targetCarbs
            targetFat = user.targetFat
            targetWeight = user.targetWeight
        }
    }

    private func saveGoals() {
        isSaving = true

        Task {
            let useCase = container.makeUpdateUserPreferencesUseCase()
            try? await useCase.execute(
                targetCalories: Int(targetCalories),
                targetProtein: targetProtein,
                targetCarbs: targetCarbs,
                targetFat: targetFat,
                targetWeight: targetWeight
            )

            isSaving = false
            onSave()
            dismiss()
        }
    }
}

/// Privacy policy view.
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                    Text("Privacy Policy")
                        .font(Typography.title1)
                        .foregroundColor(ColorPalette.textPrimary)

                    Text("Last updated: January 2025")
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)

                    Group {
                        SectionTitle("Data Collection")
                        Text("NutriBalance stores all your data locally on your device. We do not collect, transmit, or store any personal information on external servers.")

                        SectionTitle("Data Storage")
                        Text("Your nutrition logs, weight entries, and personal preferences are stored securely in your device's local storage using Apple's Core Data framework.")

                        SectionTitle("Third-Party Services")
                        Text("This app does not integrate with third-party analytics, advertising, or tracking services.")

                        SectionTitle("Your Rights")
                        Text("You can export or delete all your data at any time through the Settings menu.")

                        SectionTitle("Contact")
                        Text("For questions about this privacy policy, please contact us through the app's feedback feature.")
                    }
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textPrimary)
                }
                .padding(AppTheme.Spacing.standard)
            }
            .navigationTitle(String(localized: "settings.privacyPolicy"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SectionTitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(Typography.headline)
            .foregroundColor(ColorPalette.textPrimary)
            .padding(.top, AppTheme.Spacing.sm)
    }
}

/// About view.
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.xl) {
                Spacer()

                // App icon
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(ColorPalette.primary)
                        .frame(width: 100, height: 100)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                }

                // App name and version
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text("NutriBalance")
                        .font(Typography.title1)
                        .foregroundColor(ColorPalette.textPrimary)

                    Text("Version 1.0.0")
                        .font(Typography.body)
                        .foregroundColor(ColorPalette.textSecondary)
                }

                // Description
                Text("Your personal nutrition companion for achieving sustainable weight loss and healthy eating habits.")
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)

                Spacer()

                // Credits
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text("Made with ❤️")
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textTertiary)

                    Text("© 2025 NutriBalance")
                        .font(Typography.caption2)
                        .foregroundColor(ColorPalette.textTertiary)
                }
                .padding(.bottom, AppTheme.Spacing.xl)
            }
            .frame(maxWidth: .infinity)
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(String(localized: "settings.about"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "common.done")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(container: DependencyContainer.preview)
}
