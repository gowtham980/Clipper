import XCTest
@testable import Clipper

final class SecretDetectorTests: XCTestCase {
    func testAWSAccessKey() {
        let text = "key=AKIAIOSFODNN7EXAMPLE rest"
        XCTAssertTrue(SecretDetector.containsSecret(text))
        let kinds = SecretDetector.findSecrets(in: text).map(\.kind)
        XCTAssertTrue(kinds.contains("aws_access_key"))
    }

    func testPEMPrivateKey() {
        let pem = """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEA0Z3VS5JJcds3xfn/ygWyF6PZGFw
        -----END RSA PRIVATE KEY-----
        """
        XCTAssertTrue(SecretDetector.containsSecret(pem))
    }

    func testJWT() {
        // Minimal shape: eyJ...eyJ...sig (lengths satisfy detector)
        let jwt =
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."
            + "eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4ifQ."
            + "SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        XCTAssertTrue(SecretDetector.containsSecret(jwt))
        XCTAssertTrue(SecretDetector.findSecrets(in: jwt).contains { $0.kind == "jwt" })
    }

    func testGitHubPAT() {
        let token = "ghp_" + String(repeating: "a", count: 36)
        XCTAssertTrue(SecretDetector.containsSecret(token))
        XCTAssertTrue(SecretDetector.findSecrets(in: token).contains { $0.kind == "github_pat" })
    }

    func testGitHubFineGrained() {
        let token = "github_pat_" + String(repeating: "b", count: 22)
        XCTAssertTrue(SecretDetector.containsSecret(token))
    }

    func testHighEntropyBlob() {
        let blob = String(repeating: "AbCdEfGhIjKlMnOp", count: 4) // 64 chars
        XCTAssertTrue(SecretDetector.containsSecret(blob))
    }

    func testOrdinaryTextIsClean() {
        let text = "Hello world — stack trace at UserService.swift:42"
        XCTAssertFalse(SecretDetector.containsSecret(text))
    }

    func testRedactReplacesSpans() {
        let token = "ghp_" + String(repeating: "c", count: 36)
        let text = "Authorization: \(token)"
        let redacted = SecretDetector.redact(text)
        XCTAssertFalse(redacted.contains(token))
        XCTAssertTrue(redacted.contains("[redacted"))
    }

    func testPolicySkipSecret() {
        let token = "ghp_" + String(repeating: "d", count: 36)
        let decision = HistoryPolicy.decision(
            text: token,
            sourceBundleId: "com.apple.Terminal",
            ignoredBundleIds: [],
            secretMode: .skip,
            pasteboardIsConcealedOrTransient: false
        )
        XCTAssertEqual(decision, .skip(reason: "secret"))
    }

    func testPolicyRedactSecret() {
        let token = "ghp_" + String(repeating: "e", count: 36)
        let decision = HistoryPolicy.decision(
            text: "tok=\(token)",
            sourceBundleId: nil,
            ignoredBundleIds: [],
            secretMode: .redact,
            pasteboardIsConcealedOrTransient: false
        )
        if case .capture(let text, let redacted) = decision {
            XCTAssertTrue(redacted)
            XCTAssertFalse(text.contains(token))
        } else {
            XCTFail("expected capture")
        }
    }

    func testPolicyConcealed() {
        let decision = HistoryPolicy.decision(
            text: "password",
            sourceBundleId: nil,
            ignoredBundleIds: [],
            secretMode: .keep,
            pasteboardIsConcealedOrTransient: true
        )
        XCTAssertEqual(decision, .skip(reason: "concealed_or_transient"))
    }

    func testPolicyIgnoredApp() {
        let decision = HistoryPolicy.decision(
            text: "secret-ish",
            sourceBundleId: "com.1password.1password",
            ignoredBundleIds: Set(HistoryPolicy.defaultIgnoredBundleIds),
            secretMode: .keep,
            pasteboardIsConcealedOrTransient: false
        )
        XCTAssertEqual(decision, .skip(reason: "ignored_app"))
    }

    func testParseIgnoreList() {
        let set = HistoryPolicy.parseIgnoreList("com.a\ncom.b, com.c")
        XCTAssertEqual(set, Set(["com.a", "com.b", "com.c"]))
    }
}
