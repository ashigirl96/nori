import XCTest
import AppKit

#if canImport(nori_DEV)
@testable import nori_DEV
#elseif canImport(nori)
@testable import nori
#endif

@MainActor
final class GhosttyEnsureFocusWindowActivationTests: XCTestCase {
    func testAllowsActivationForActiveManager() {
        let activeManager = WorkspaceManager()
        let otherManager = WorkspaceManager()
        let targetWindow = NSWindow()
        let otherWindow = NSWindow()

        XCTAssertTrue(
            shouldAllowEnsureFocusWindowActivation(
                activeWorkspaceManager: activeManager,
                targetWorkspaceManager: activeManager,
                keyWindow: targetWindow,
                mainWindow: targetWindow,
                targetWindow: targetWindow
            )
        )
        XCTAssertFalse(
            shouldAllowEnsureFocusWindowActivation(
                activeWorkspaceManager: activeManager,
                targetWorkspaceManager: otherManager,
                keyWindow: otherWindow,
                mainWindow: otherWindow,
                targetWindow: targetWindow
            )
        )
    }

    func testAllowsActivationWhenAppHasNoKeyAndNoMainWindow() {
        let targetManager = WorkspaceManager()
        let targetWindow = NSWindow()

        XCTAssertTrue(
            shouldAllowEnsureFocusWindowActivation(
                activeWorkspaceManager: nil,
                targetWorkspaceManager: targetManager,
                keyWindow: nil,
                mainWindow: nil,
                targetWindow: targetWindow
            )
        )
        XCTAssertFalse(
            shouldAllowEnsureFocusWindowActivation(
                activeWorkspaceManager: nil,
                targetWorkspaceManager: targetManager,
                keyWindow: NSWindow(),
                mainWindow: nil,
                targetWindow: targetWindow
            )
        )
        XCTAssertFalse(
            shouldAllowEnsureFocusWindowActivation(
                activeWorkspaceManager: nil,
                targetWorkspaceManager: targetManager,
                keyWindow: nil,
                mainWindow: NSWindow(),
                targetWindow: targetWindow
            )
        )
    }
}
