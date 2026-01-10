import SwiftUI

/// Main tab navigation for the app.
struct MainTabView: View {
    let container: DependencyContainer
    @State private var selectedTab: Tab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(container: container)
                .tabItem {
                    Label(Tab.today.title, systemImage: Tab.today.icon)
                }
                .tag(Tab.today)

            AnalyticsView(container: container)
                .tabItem {
                    Label(Tab.analytics.title, systemImage: Tab.analytics.icon)
                }
                .tag(Tab.analytics)

            DashboardView(container: container)
                .tabItem {
                    Label(Tab.dashboard.title, systemImage: Tab.dashboard.icon)
                }
                .tag(Tab.dashboard)

            ProgressView(container: container)
                .tabItem {
                    Label(Tab.progress.title, systemImage: Tab.progress.icon)
                }
                .tag(Tab.progress)

            SettingsView(container: container)
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(ColorPalette.primary)
    }
}

// MARK: - Tab Definition

enum Tab: String, CaseIterable, Identifiable {
    case today
    case analytics
    case dashboard
    case progress
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            return String(localized: "tab.today", defaultValue: "Today")
        case .analytics:
            return String(localized: "tab.analytics", defaultValue: "Analytics")
        case .dashboard:
            return String(localized: "tab.dashboard", defaultValue: "Dashboard")
        case .progress:
            return String(localized: "tab.progress", defaultValue: "Progress")
        case .settings:
            return String(localized: "tab.settings", defaultValue: "Settings")
        }
    }

    var icon: String {
        switch self {
        case .today:
            return "calendar"
        case .analytics:
            return "chart.bar.fill"
        case .dashboard:
            return "square.grid.2x2.fill"
        case .progress:
            return "chart.line.uptrend.xyaxis"
        case .settings:
            return "gearshape.fill"
        }
    }
}

#Preview {
    MainTabView(container: DependencyContainer.preview)
}
