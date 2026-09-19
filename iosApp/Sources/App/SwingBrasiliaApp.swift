import SwiftUI

@main
struct SwingBrasiliaApp: App {
    @StateObject private var ageGate = AgeGateStore()

    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(ageGate)
        }
    }
}
