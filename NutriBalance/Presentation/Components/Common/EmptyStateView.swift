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

// MARK: - Toast System

/// Toast message type.
enum ToastType {
    case success
    case error
    case info
    case undo

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .undo: return "arrow.uturn.backward.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return ColorPalette.success
        case .error: return ColorPalette.error
        case .info: return ColorPalette.primary
        case .undo: return ColorPalette.warning
        }
    }
}

/// Toast message data.
struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let type: ToastType
    let message: String
    var undoAction: (() -> Void)?

    static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool {
        lhs.id == rhs.id
    }
}

/// Observable toast manager for showing toast notifications.
@MainActor
class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published var currentToast: ToastMessage?
    private var dismissTask: Task<Void, Never>?

    private init() {}

    func show(_ message: String, type: ToastType = .info, duration: TimeInterval = 3.0, undoAction: (() -> Void)? = nil) {
        dismissTask?.cancel()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentToast = ToastMessage(type: type, message: message, undoAction: undoAction)
        }

        dismissTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            dismiss()
        }
    }

    func showSuccess(_ message: String = L("toast.saved")) {
        HapticManager.shared.success()
        show(message, type: .success)
    }

    func showError(_ message: String = L("toast.error")) {
        HapticManager.shared.error()
        show(message, type: .error)
    }

    func showUndo(_ message: String, action: @escaping () -> Void) {
        show(message, type: .undo, duration: 5.0, undoAction: action)
    }

    func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            currentToast = nil
        }
    }
}

/// Toast notification view.
struct ToastView: View {
    let message: String
    var type: ToastType = .info
    var undoAction: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: type.icon)
                .font(.system(size: 16))
                .foregroundColor(.white)

            Text(message)
                .font(Typography.callout)
                .foregroundColor(.white)

            Spacer()

            if let undoAction = undoAction {
                Button(action: {
                    undoAction()
                    onDismiss?()
                }) {
                    Text(L("common.undo"))
                        .font(Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }

            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.standard)
        .padding(.vertical, AppTheme.Spacing.md)
        .background(type.color)
        .cornerRadius(AppTheme.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

/// View modifier to add toast overlay to any view.
struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager = ToastManager.shared

    func body(content: Content) -> some View {
        ZStack {
            content

            VStack {
                Spacer()

                if let toast = toastManager.currentToast {
                    ToastView(
                        message: toast.message,
                        type: toast.type,
                        undoAction: toast.undoAction,
                        onDismiss: toastManager.dismiss
                    )
                    .padding(.horizontal, AppTheme.Spacing.standard)
                    .padding(.bottom, AppTheme.Spacing.xl)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

extension View {
    /// Adds toast notification overlay to the view.
    func withToast() -> some View {
        modifier(ToastModifier())
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
                ToastView(message: L("toast.saved"), type: .success)
                ToastView(message: L("toast.error"), type: .error)
                ToastView(message: L("toast.deleted"), type: .undo, undoAction: {})
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
