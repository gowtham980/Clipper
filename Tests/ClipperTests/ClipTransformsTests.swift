import XCTest
@testable import Clipper

final class ClipTransformsTests: XCTestCase {
    func testTrim() throws {
        let out = try ClipTransforms.apply(.trim, to: "  hello\n")
        XCTAssertEqual(out, "hello")
    }

    func testJSONPrettyObject() throws {
        let out = try ClipTransforms.apply(.jsonPretty, to: #"{"b":1,"a":2}"#)
        XCTAssertTrue(out.contains("\n"))
        XCTAssertTrue(out.contains("\"a\""))
        XCTAssertTrue(out.contains("\"b\""))
        // sortedKeys → a before b
        let aPos = out.range(of: "\"a\"")!.lowerBound
        let bPos = out.range(of: "\"b\"")!.lowerBound
        XCTAssertTrue(aPos < bPos)
    }

    func testJSONPrettyInvalid() {
        XCTAssertThrowsError(try ClipTransforms.apply(.jsonPretty, to: "not-json{")) { error in
            XCTAssertEqual(error as? ClipTransformError, .invalidJSON)
        }
    }

    func testBase64RoundTrip() throws {
        let encoded = try ClipTransforms.apply(.base64Encode, to: "Clipper")
        let decoded = try ClipTransforms.apply(.base64Decode, to: encoded)
        XCTAssertEqual(decoded, "Clipper")
    }

    func testBase64Invalid() {
        XCTAssertThrowsError(try ClipTransforms.apply(.base64Decode, to: "%%%not-b64%%%")) { error in
            XCTAssertEqual(error as? ClipTransformError, .invalidBase64)
        }
    }

    func testURLEncodeDecode() throws {
        let encoded = try ClipTransforms.apply(.urlEncode, to: "a b&c")
        XCTAssertFalse(encoded.contains(" "))
        let decoded = try ClipTransforms.apply(.urlDecode, to: encoded)
        XCTAssertEqual(decoded, "a b&c")
    }

    func testURLDecodeIdentityOnPlain() throws {
        let out = try ClipTransforms.apply(.urlDecode, to: "plain")
        XCTAssertEqual(out, "plain")
    }
}
