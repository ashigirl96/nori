import XCTest

#if canImport(nori_DEV)
@testable import nori_DEV
#elseif canImport(nori)
@testable import nori
#endif

final class SidebarWidthPolicyTests: XCTestCase {
    func testContentViewClampAllowsNarrowSidebarBelowLegacyMinimum() {
        XCTAssertEqual(
            ContentView.clampedSidebarWidth(184, maximumWidth: 600),
            184,
            accuracy: 0.001
        )
    }
}
