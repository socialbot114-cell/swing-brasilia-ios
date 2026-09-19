import XCTest
@testable import SwingBrasilia

final class AgeGateStoreTests: XCTestCase {

    func testStartsUnconfirmedWithFreshDefaults() {
        let suite = "AgeGateStoreTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = AgeGateStore(defaults: defaults)
        XCTAssertFalse(store.isConfirmed)
    }

    func testConfirmPersistsConfirmation() {
        let suite = "AgeGateStoreTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = AgeGateStore(defaults: defaults)
        store.confirm()
        XCTAssertTrue(store.isConfirmed)

        let reloaded = AgeGateStore(defaults: defaults)
        XCTAssertTrue(reloaded.isConfirmed)
    }
}
