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
                    Text(L("settings.profile"))
                }

                // Goals section
                Section {
                    SettingsRow(
                        icon: "target",
                        title: L("settings.nutritionGoals"),
                        value: "\(viewModel.user?.dailyCalorieGoal ?? 0) kcal"
                    )
                    .onTapGesture { showEditGoals = true }

                    SettingsRow(
                        icon: "scalemass",
                        title: L("settings.weightGoal"),
                        value: "\(String(format: "%.1f", viewModel.user?.targetWeight ?? 0)) kg"
                    )
                    .onTapGesture { showEditGoals = true }
                } header: {
                    Text(L("settings.goals"))
                }

                // Preferences section
                Section {
                    Toggle(isOn: $viewModel.notificationsEnabled) {
                        SettingsLabel(icon: "bell.fill", title: L("settings.notifications"))
                    }
                    .onChange(of: viewModel.notificationsEnabled) { newValue in
                        Task { await viewModel.updateNotifications(enabled: newValue) }
                    }

                    Picker(selection: $viewModel.selectedLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    } label: {
                        SettingsLabel(icon: "globe", title: L("settings.language"))
                    }
                    .onChange(of: viewModel.selectedLanguage) { newLanguage in
                        Task { await viewModel.updateLanguage(language: newLanguage) }
                    }
                } header: {
                    Text(L("settings.preferences"))
                }

                // Data section
                Section {
                    Button(action: { viewModel.exportData() }) {
                        SettingsLabel(icon: "square.and.arrow.up", title: L("settings.exportData"))
                    }

                    Button(role: .destructive, action: { viewModel.showDeleteConfirmation = true }) {
                        SettingsLabel(
                            icon: "trash",
                            title: L("settings.deleteData"),
                            color: ColorPalette.error
                        )
                    }
                } header: {
                    Text(L("settings.data"))
                }

                // About section
                Section {
                    Button(action: { showPrivacyPolicy = true }) {
                        SettingsLabel(icon: "hand.raised.fill", title: L("settings.privacyPolicy"))
                    }

                    Button(action: { showAbout = true }) {
                        SettingsLabel(icon: "info.circle", title: L("settings.about"))
                    }

                    SettingsRow(
                        icon: "number",
                        title: L("settings.version"),
                        value: viewModel.appVersion
                    )
                } header: {
                    Text(L("settings.about"))
                }
            }
            .navigationTitle(L("settings.title"))
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
            .alert(L("settings.deleteConfirmTitle"), isPresented: $viewModel.showDeleteConfirmation) {
                Button(L("common.cancel"), role: .cancel) {}
                Button(L("common.delete"), role: .destructive) {
                    Task { await viewModel.deleteAllData() }
                }
            } message: {
                Text(L("settings.deleteConfirmMessage"))
            }
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
                Text(user?.displayName ?? L("settings.noName"))
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
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var height: Double = 175
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledTextField(
                        label: L("profile.firstName"),
                        text: $firstName,
                        placeholder: L("profile.firstNamePlaceholder"),
                        isRequired: true
                    )

                    LabeledTextField(
                        label: L("profile.lastName"),
                        text: $lastName,
                        placeholder: L("profile.lastNamePlaceholder")
                    )

                    LabeledTextField(
                        label: L("profile.email"),
                        text: $email,
                        placeholder: L("profile.emailPlaceholder")
                    )
                }

                Section {
                    NumberInputField(
                        title: L("profile.height"),
                        value: $height,
                        unit: "cm",
                        step: 1,
                        range: 100...250
                    )
                }
            }
            .navigationTitle(L("profile.edit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("common.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(L("common.save")) {
                        saveProfile()
                    }
                    .disabled(firstName.isEmpty || isSaving)
                }
            }
            .task {
                await loadProfile()
            }
        }
    }

    private func loadProfile() async {
        let repository = container.userRepository
        if let user = try? await repository.getCurrentUser() {
            firstName = user.firstName
            lastName = user.lastName ?? ""
            email = user.email ?? ""
            height = user.height ?? 175
        }
    }

    private func saveProfile() {
        isSaving = true

        Task {
            let useCase = container.makeUpdateUserPreferencesUseCase()
            try? await useCase.execute(
                firstName: firstName,
                lastName: lastName.isEmpty ? nil : lastName,
                email: email.isEmpty ? nil : email,
                height: height
            )

            isSaving = false
            ToastManager.shared.showSuccess(L("toast.saved"))
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
                Section(L("goals.nutrition")) {
                    NumberInputField(
                        title: L("goals.calories"),
                        value: $targetCalories,
                        unit: "kcal",
                        step: 50,
                        range: 1000...5000
                    )

                    NumberInputField(
                        title: L("goals.protein"),
                        value: $targetProtein,
                        unit: "g",
                        step: 5,
                        range: 30...300
                    )

                    NumberInputField(
                        title: L("goals.carbs"),
                        value: $targetCarbs,
                        unit: "g",
                        step: 10,
                        range: 50...500
                    )

                    NumberInputField(
                        title: L("goals.fat"),
                        value: $targetFat,
                        unit: "g",
                        step: 5,
                        range: 20...200
                    )
                }

                Section(L("goals.weight")) {
                    NumberInputField(
                        title: L("goals.targetWeight"),
                        value: $targetWeight,
                        unit: "kg",
                        step: 0.5,
                        range: 30...300,
                        decimalPlaces: 1
                    )
                }
            }
            .navigationTitle(L("goals.edit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("common.cancel")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(L("common.save")) {
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
        let repository = container.userRepository
        if let user = try? await repository.getCurrentUser() {
            targetCalories = Double(user.dailyCalorieGoal)
            targetProtein = user.targetProtein ?? 0
            targetCarbs = user.targetCarbs ?? 0
            targetFat = user.targetFat ?? 0
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
            ToastManager.shared.showSuccess(L("toast.saved"))
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
                    Text(L("privacy.title"))
                        .font(Typography.title1)
                        .foregroundColor(ColorPalette.textPrimary)

                    Text(L("privacy.lastUpdated"))
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textSecondary)

                    Group {
                        SectionTitle(L("privacy.dataCollection.title"))
                        Text(L("privacy.dataCollection.content"))

                        SectionTitle(L("privacy.dataStorage.title"))
                        Text(L("privacy.dataStorage.content"))

                        SectionTitle(L("privacy.thirdParty.title"))
                        Text(L("privacy.thirdParty.content"))

                        SectionTitle(L("privacy.rights.title"))
                        Text(L("privacy.rights.content"))

                        SectionTitle(L("privacy.contact.title"))
                        Text(L("privacy.contact.content"))
                    }
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textPrimary)
                }
                .padding(AppTheme.Spacing.standard)
            }
            .navigationTitle(L("settings.privacyPolicy"))
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
                    Text(L("about.appName"))
                        .font(Typography.title1)
                        .foregroundColor(ColorPalette.textPrimary)

                    Text(String(format: L("about.version"), "1.0.0"))
                        .font(Typography.body)
                        .foregroundColor(ColorPalette.textSecondary)
                }

                // Description
                Text(L("about.description"))
                    .font(Typography.body)
                    .foregroundColor(ColorPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.xl)

                Spacer()

                // Credits
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text(L("about.madeWith"))
                        .font(Typography.caption1)
                        .foregroundColor(ColorPalette.textTertiary)

                    Text(L("about.copyright"))
                        .font(Typography.caption2)
                        .foregroundColor(ColorPalette.textTertiary)
                }
                .padding(.bottom, AppTheme.Spacing.xl)
            }
            .frame(maxWidth: .infinity)
            .background(ColorPalette.backgroundSecondary)
            .navigationTitle(L("settings.about"))
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
    SettingsView(container: DependencyContainer.preview)
}
