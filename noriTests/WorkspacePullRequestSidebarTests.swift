import XCTest

#if canImport(nori_DEV)
@testable import nori_DEV
#elseif canImport(nori)
@testable import nori
#endif

@MainActor
final class WorkspacePullRequestSidebarTests: XCTestCase {
    func testSidebarPullRequestsIgnoreStaleWorkspaceLevelCacheWithoutPanelState() throws {
        let workspace = Workspace(title: "Test")
        let panelId = UUID()
        let staleURL = try XCTUnwrap(URL(string: "https://github.com/manaflow-ai/nori/pull/1640"))

        workspace.pullRequest = SidebarPullRequestState(
            number: 1640,
            label: "PR",
            url: staleURL,
            status: .open,
            branch: "main"
        )
        workspace.gitBranch = SidebarGitBranchState(branch: "main", isDirty: false)

        XCTAssertEqual(workspace.sidebarPullRequestsInDisplayOrder(orderedPanelIds: [panelId]), [])
    }

    func testSidebarPullRequestsFilterBranchMismatchPerPanel() throws {
        let workspace = Workspace(title: "Test")
        let panelId = UUID()
        let staleURL = try XCTUnwrap(URL(string: "https://github.com/manaflow-ai/nori/pull/1640"))

        workspace.panelGitBranches[panelId] = SidebarGitBranchState(branch: "main", isDirty: false)
        workspace.panelPullRequests[panelId] = SidebarPullRequestState(
            number: 1640,
            label: "PR",
            url: staleURL,
            status: .open,
            branch: "feature/old"
        )

        XCTAssertEqual(workspace.sidebarPullRequestsInDisplayOrder(orderedPanelIds: [panelId]), [])
    }

    func testSidebarPullRequestsPreferBestStateAcrossPanels() throws {
        let workspace = Workspace(title: "Test")
        let firstPanelId = UUID()
        let secondPanelId = UUID()
        let url = try XCTUnwrap(URL(string: "https://github.com/manaflow-ai/nori/pull/1640"))

        workspace.panelGitBranches[firstPanelId] = SidebarGitBranchState(branch: "feature/work", isDirty: false)
        workspace.panelGitBranches[secondPanelId] = SidebarGitBranchState(branch: "feature/work", isDirty: false)
        workspace.panelPullRequests[firstPanelId] = SidebarPullRequestState(
            number: 1640,
            label: "PR",
            url: url,
            status: .open,
            branch: "feature/work",
            isStale: true
        )
        workspace.panelPullRequests[secondPanelId] = SidebarPullRequestState(
            number: 1640,
            label: "PR",
            url: url,
            status: .merged,
            branch: "feature/work"
        )

        XCTAssertEqual(
            workspace.sidebarPullRequestsInDisplayOrder(orderedPanelIds: [firstPanelId, secondPanelId]),
            [
                SidebarPullRequestState(
                    number: 1640,
                    label: "PR",
                    url: url,
                    status: .merged,
                    branch: "feature/work"
                )
            ]
        )
    }
}
