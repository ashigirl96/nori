import XCTest

#if canImport(nori_DEV)
@testable import nori_DEV
#elseif canImport(nori)
@testable import nori
#endif

@MainActor
final class WorkspaceManagerSessionSnapshotTests: XCTestCase {
    func testSessionSnapshotSerializesWorkspacesAndRestoreRebuildsSelection() {
        let manager = WorkspaceManager()
        guard let firstWorkspace = manager.selectedWorkspace else {
            XCTFail("Expected initial workspace")
            return
        }
        firstWorkspace.setCustomTitle("First")

        let secondWorkspace = manager.addWorkspace(select: true)
        secondWorkspace.setCustomTitle("Second")
        XCTAssertEqual(manager.workspaces.count, 2)
        XCTAssertEqual(manager.selectedWorkspaceId, secondWorkspace.id)

        let snapshot = manager.sessionSnapshot(includeScrollback: false)
        XCTAssertEqual(snapshot.workspaces.count, 2)
        XCTAssertEqual(snapshot.selectedWorkspaceIndex, 1)

        let restored = WorkspaceManager()
        restored.restoreSessionSnapshot(snapshot)

        XCTAssertEqual(restored.workspaces.count, 2)
        XCTAssertEqual(restored.selectedWorkspaceId, restored.workspaces[1].id)
        XCTAssertEqual(restored.workspaces[0].customTitle, "First")
        XCTAssertEqual(restored.workspaces[1].customTitle, "Second")
    }

    func testRestoreSessionSnapshotWithNoWorkspacesKeepsSingleFallbackWorkspace() {
        let manager = WorkspaceManager()
        let emptySnapshot = SessionWorkspaceManagerSnapshot(
            selectedWorkspaceIndex: nil,
            workspaces: []
        )

        manager.restoreSessionSnapshot(emptySnapshot)

        XCTAssertEqual(manager.workspaces.count, 1)
        XCTAssertNotNil(manager.selectedWorkspaceId)
    }

    func testSessionSnapshotExcludesRemoteWorkspacesFromRestore() throws {
        let manager = WorkspaceManager()
        let remoteWorkspace = manager.addWorkspace(select: true)
        let configuration = WorkspaceRemoteConfiguration(
            destination: "nori-macmini",
            port: nil,
            identityFile: nil,
            sshOptions: [],
            localProxyPort: nil,
            relayPort: 64001,
            relayID: "relay-test",
            relayToken: String(repeating: "b", count: 64),
            localSocketPath: "/tmp/nori-test.sock",
            terminalStartupCommand: "ssh nori-macmini"
        )
        remoteWorkspace.configureRemoteConnection(configuration, autoConnect: false)
        let paneId = try XCTUnwrap(remoteWorkspace.bonsplitController.allPaneIds.first)
        _ = remoteWorkspace.newBrowserSurface(inPane: paneId, url: URL(string: "http://localhost:3000"), focus: false)

        let snapshot = manager.sessionSnapshot(includeScrollback: false)

        XCTAssertEqual(snapshot.workspaces.count, 1)
        XCTAssertNil(snapshot.selectedWorkspaceIndex)
        XCTAssertFalse(snapshot.workspaces.contains { $0.processTitle == remoteWorkspace.title })
    }
}
