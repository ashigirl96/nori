import XCTest

#if canImport(nori_DEV)
@testable import nori_DEV
#elseif canImport(nori)
@testable import nori
#endif

final class SidebarMarkdownRendererTests: XCTestCase {
    func testRenderWorkspaceDescriptionPreservesLineBreaks() throws {
        let rendered = try XCTUnwrap(
            SidebarMarkdownRenderer.renderWorkspaceDescription("First line\nSecond line")
        )

        XCTAssertEqual(String(rendered.characters), "First line\nSecond line")
    }

    func testRenderWorkspaceDescriptionPreservesInlineMarkdownAttributes() throws {
        let rendered = try XCTUnwrap(
            SidebarMarkdownRenderer.renderWorkspaceDescription("**Bold**\n[Link](https://example.com)")
        )

        XCTAssertEqual(String(rendered.characters), "Bold\nLink")
        XCTAssertTrue(rendered.runs.contains { $0.inlinePresentationIntent != nil })
        XCTAssertTrue(
            rendered.runs.contains { $0.link == URL(string: "https://example.com") }
        )
    }
}
