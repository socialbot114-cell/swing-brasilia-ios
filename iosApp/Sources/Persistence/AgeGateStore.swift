import Foundation

final class AgeGateStore: ObservableObject {
    static let confirmationKey = "swing-brasilia-age-confirmed"

    @Published private(set) var isConfirmed: Bool

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isConfirmed = defaults.bool(forKey: AgeGateStore.confirmationKey)
    }

    func confirm() {
        isConfirmed = true
        defaults.set(true, forKey: AgeGateStore.confirmationKey)
    }
}
