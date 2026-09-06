import XCTest
@testable import Clipper

final class HistoryLimitTests: XCTestCase {
    func testDropsOldestUnpinnedAndKeepsOrder() {
        let items = [
            ClipItem(content: "new", isPinned: false),
            ClipItem(content: "pinned", isPinned: true),
            ClipItem(content: "mid", isPinned: false),
            ClipItem(content: "old", isPinned: false),
            ClipItem(content: "oldest", isPinned: false),
        ]

        let trimmed = items.clippedToHistoryLimit(3)
        XCTAssertEqual(trimmed.map(\.content), ["new", "pinned", "mid"])
    }

    func testKeepsPinnedEvenWhenOverLimit() {
        let items = [
            ClipItem(content: "a", isPinned: true),
            ClipItem(content: "b", isPinned: true),
            ClipItem(content: "c", isPinned: true),
        ]

        let trimmed = items.clippedToHistoryLimit(1)
        XCTAssertEqual(trimmed.map(\.content), ["a", "b", "c"])
    }

    func testNoOpWhenUnderCap() {
        let items = [
            ClipItem(content: "a", isPinned: false),
            ClipItem(content: "b", isPinned: false),
        ]
        XCTAssertEqual(items.clippedToHistoryLimit(10), items)
    }

    func testZeroLimitKeepsOnlyPinned() {
        let items = [
            ClipItem(content: "p", isPinned: true),
            ClipItem(content: "u", isPinned: false),
        ]
        let trimmed = items.clippedToHistoryLimit(0)
        XCTAssertEqual(trimmed.map(\.content), ["p"])
    }
}
