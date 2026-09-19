import SwiftUI

struct RootView: View {
    @EnvironmentObject private var ageGate: AgeGateStore
    @StateObject private var catalog = VenueCatalog()
    @State private var selection: Int = RootView.initialSelection()

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem { Label("Início", systemImage: "house.fill") }
                .tag(0)
            DirectoryView()
                .tabItem { Label("Explorar", systemImage: "map.fill") }
                .tag(1)
            RulesView()
                .tabItem { Label("Comunidade", systemImage: "bubble.left.and.bubble.right.fill") }
                .tag(2)
            BusinessView()
                .tabItem { Label("Tecnologia", systemImage: "sparkles") }
                .tag(3)
        }
        .tint(SwingTheme.Palette.brand)
        .environmentObject(catalog)
        .fullScreenCover(isPresented: ageGateBinding) {
            AgeGateView().environmentObject(ageGate)
        }
#if DEBUG
        .onAppear {
            if ProcessInfo.processInfo.environment["SWING_SKIP_AGE"] == "1" {
                ageGate.confirm()
            }
        }
#endif
    }

    private var ageGateBinding: Binding<Bool> {
        Binding(
            get: { !ageGate.isConfirmed },
            set: { _ in }
        )
    }

    private static func initialSelection() -> Int {
        switch ProcessInfo.processInfo.environment["SWING_TAB"] {
        case "1": return 1
        case "2": return 2
        case "3": return 3
        default: return 0
        }
    }
}
