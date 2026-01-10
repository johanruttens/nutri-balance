import SwiftUI

struct ContentView: View {
    let container: DependencyContainer
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.isOnboardingComplete {
                MainTabView(container: container)
            } else {
                OnboardingContainerView(container: container)
            }
        }
        .animation(.easeInOut, value: appState.isOnboardingComplete)
    }
}

#Preview {
    ContentView(container: DependencyContainer.preview)
        .environmentObject(AppState())
}
