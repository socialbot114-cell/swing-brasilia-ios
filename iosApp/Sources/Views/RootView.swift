import SwiftUI

struct RootView: View {
    @EnvironmentObject private var ageGate: AgeGateStore
    @StateObject private var catalog = VenueCatalog()

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Início", systemImage: "house.fill") }
            DirectoryView()
                .tabItem { Label("Explorar", systemImage: "map.fill") }
            RulesView()
                .tabItem { Label("Comunidade", systemImage: "bubble.left.and.bubble.right.fill") }
            BusinessView()
                .tabItem { Label("Tecnologia", systemImage: "sparkles") }
        }
        .tint(SwingTheme.Palette.brand)
        .environmentObject(catalog)
        .fullScreenCover(isPresented: ageGateBinding) {
            AgeGateView().environmentObject(ageGate)
        }
    }

    private var ageGateBinding: Binding<Bool> {
        Binding(
            get: { !ageGate.isConfirmed },
            set: { _ in }
        )
    }
}
