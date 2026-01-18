import UIKit

/// Manager for haptic feedback throughout the app.
final class HapticManager {
    static let shared = HapticManager()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private init() {
        // Prepare generators for faster response
        prepareGenerators()
    }

    private func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }

    // MARK: - Impact Feedback

    /// Light impact for subtle interactions (e.g., button taps).
    func lightImpact() {
        impactLight.impactOccurred()
        impactLight.prepare()
    }

    /// Medium impact for standard interactions (e.g., toggles, selections).
    func mediumImpact() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }

    /// Heavy impact for significant interactions (e.g., completing a goal).
    func heavyImpact() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }

    // MARK: - Selection Feedback

    /// Selection changed feedback (e.g., picker changes).
    func selectionChanged() {
        selectionFeedback.selectionChanged()
        selectionFeedback.prepare()
    }

    // MARK: - Notification Feedback

    /// Success feedback (e.g., save completed, goal reached).
    func success() {
        notificationFeedback.notificationOccurred(.success)
        notificationFeedback.prepare()
    }

    /// Warning feedback (e.g., approaching limit).
    func warning() {
        notificationFeedback.notificationOccurred(.warning)
        notificationFeedback.prepare()
    }

    /// Error feedback (e.g., save failed, validation error).
    func error() {
        notificationFeedback.notificationOccurred(.error)
        notificationFeedback.prepare()
    }
}
