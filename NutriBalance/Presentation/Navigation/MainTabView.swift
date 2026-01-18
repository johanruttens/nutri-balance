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

            WeightProgressView(container: container)
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
            return L("tab.today")
        case .analytics:
            return L("tab.analytics")
        case .dashboard:
            return L("tab.dashboard")
        case .progress:
            return L("tab.progress")
        case .settings:
            return L("tab.settings")
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
