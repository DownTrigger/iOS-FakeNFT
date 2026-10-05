import XCTest
@testable import iOS_FakeNFT_Extended

final class FormBodyTests: XCTestCase {

    private func string(_ body: FormBody) -> String {
        String(decoding: body.data, as: UTF8.self)
    }

    func testEmptyBodyHasNoData() {
        XCTAssertTrue(FormBody().data.isEmpty)
    }

    func testPairsKeepInsertionOrder() {
        var body = FormBody()
        body.add("b", "2")
        body.add("a", "1")

        XCTAssertEqual(string(body), "b=2&a=1")
    }

    func testArrayRepeatsKey() {
        var body = FormBody()
        body.add("likes", ["x", "y"])

        XCTAssertEqual(string(body), "likes=x&likes=y")
    }

    func testEmptyArrayAddsNothingByDefault() {
        var body = FormBody()
        body.add("name", "n")
        body.add("likes", [])

        XCTAssertEqual(string(body), "name=n")
    }

    func testEmptyArrayAddsProvidedValue() {
        var body = FormBody()
        body.add("likes", [], whenEmpty: "null")

        XCTAssertEqual(string(body), "likes=null")
    }

    func testNonEmptyArrayIgnoresEmptyValue() {
        var body = FormBody()
        body.add("likes", ["x"], whenEmpty: "null")

        XCTAssertEqual(string(body), "likes=x")
    }

    func testReservedCharactersAreEscaped() {
        var body = FormBody()
        body.add("k", "a b&c+d=e")

        XCTAssertEqual(string(body), "k=a%20b%26c%2Bd%3De")
    }

    func testKeysAreEscaped() {
        var body = FormBody()
        body.add("a&b=c", "v")

        XCTAssertEqual(string(body), "a%26b%3Dc=v")
    }

    func testCyrillicIsPercentEncodedAsUTF8() {
        var body = FormBody()
        body.add("name", "Дом")

        XCTAssertEqual(string(body), "name=%D0%94%D0%BE%D0%BC")
    }

    func testUnreservedCharactersAreUntouched() {
        var body = FormBody()
        body.add("k", "AZaz09-._~")

        XCTAssertEqual(string(body), "k=AZaz09-._~")
    }
}
