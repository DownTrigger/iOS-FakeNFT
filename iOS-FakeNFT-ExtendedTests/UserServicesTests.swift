import XCTest
@testable import iOS_FakeNFT_Extended

private final class NetworkClientMock: NetworkClient, @unchecked Sendable {
    var responses: [Result<Data, Error>] = []
    private(set) var requests: [NetworkRequest] = []

    func send(request: NetworkRequest) async throws -> Data {
        requests.append(request)
        guard !responses.isEmpty else {
            throw NetworkClientError.urlSessionError
        }
        return try responses.removeFirst().get()
    }

    func send<T: Decodable>(request: NetworkRequest) async throws -> T {
        let data: Data = try await send(request: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

private func profileJSON(likes: [String]) -> Data {
    let list = likes.map { "\"\($0)\"" }.joined(separator: ",")
    let json = """
    {"name":"Name","avatar":"","description":"Bio","website":"","nfts":["n1"],"likes":[\(list)],"id":"1"}
    """
    return Data(json.utf8)
}

private func orderJSON(nfts: [String]) -> Data {
    let list = nfts.map { "\"\($0)\"" }.joined(separator: ",")
    return Data("{\"nfts\":[\(list)],\"id\":\"1\"}".utf8)
}

private func string(_ data: Data?) -> String {
    String(decoding: data ?? Data(), as: UTF8.self)
}

final class IdChangeTests: XCTestCase {

    func testAddNewAppendsToEnd() {
        XCTAssertEqual(IdChange.add("c").apply(to: ["a", "b"]), ["a", "b", "c"])
    }

    func testAddExistingDoesNotDuplicate() {
        XCTAssertEqual(IdChange.add("a").apply(to: ["a", "b"]), ["a", "b"])
    }

    func testRemoveDropsAllOccurrences() {
        XCTAssertEqual(IdChange.remove("a").apply(to: ["a", "b", "a"]), ["b"])
    }

    func testRemoveMissingKeepsList() {
        XCTAssertEqual(IdChange.remove("x").apply(to: ["a", "b"]), ["a", "b"])
    }
}

final class UserRequestsTests: XCTestCase {

    private func profile(description: String = "Bio", avatar: String? = "av", website: String? = "site") -> UserProfile {
        UserProfile(
            id: "1", name: "Name", description: description,
            website: website, avatar: avatar, nfts: ["n1"], likes: []
        )
    }

    func testProfileRequestsMethodAndPath() {
        let get = UserProfileRequest()
        let put = UserProfileUpdateRequest(profile: profile(), likes: [])
        XCTAssertEqual(get.httpMethod, .get)
        XCTAssertEqual(put.httpMethod, .put)
        XCTAssertEqual(get.endpoint?.path, "/api/v1/profile/1")
        XCTAssertEqual(put.endpoint?.path, "/api/v1/profile/1")
    }

    func testProfileBodyContainsAllFieldsAndRepeatedLikes() {
        let request = UserProfileUpdateRequest(profile: profile(), likes: ["a", "b"])
        XCTAssertEqual(
            string(request.rawBody),
            "name=Name&description=Bio&avatar=av&website=site&likes=a&likes=b"
        )
    }

    func testProfileBodyWithEmptyLikesSendsNull() {
        let request = UserProfileUpdateRequest(profile: profile(avatar: nil, website: nil), likes: [])
        XCTAssertEqual(string(request.rawBody), "name=Name&description=Bio&avatar=&website=&likes=null")
    }

    func testProfileBodyEscapesSpecialCharacters() {
        let request = UserProfileUpdateRequest(profile: profile(description: "a&b=c d+é"), likes: [])
        XCTAssertTrue(string(request.rawBody).contains("description=a%26b%3Dc%20d%2B%C3%A9&"))
    }

    func testOrderRequestsMethodAndPath() {
        let get = UserOrderRequest()
        let put = UserOrderUpdateRequest(nfts: [])
        XCTAssertEqual(get.httpMethod, .get)
        XCTAssertEqual(put.httpMethod, .put)
        XCTAssertEqual(get.endpoint?.path, "/api/v1/orders/1")
        XCTAssertEqual(put.endpoint?.path, "/api/v1/orders/1")
    }

    func testOrderBodyRepeatsNfts() {
        XCTAssertEqual(string(UserOrderUpdateRequest(nfts: ["a", "b"]).rawBody), "nfts=a&nfts=b")
    }

    func testEmptyOrderBodyIsEmpty() {
        XCTAssertEqual(UserOrderUpdateRequest(nfts: []).rawBody, Data())
    }
}

final class UserProfileServiceTests: XCTestCase {

    func testUpdateLikesDoesGetThenPutAndReturnsPutResponse() async throws {
        let client = NetworkClientMock()
        client.responses = [.success(profileJSON(likes: ["a"])), .success(profileJSON(likes: ["a", "b"]))]
        let service = UserProfileServiceImpl(networkClient: client)

        let result = try await service.updateLikes(.add("b"))

        XCTAssertEqual(result.likes, ["a", "b"])
        XCTAssertEqual(client.requests.map(\.httpMethod), [.get, .put])
        XCTAssertEqual(string(client.requests.last?.rawBody), "name=Name&description=Bio&avatar=&website=&likes=a&likes=b")
    }

    func testUpdateLikesWithoutChangeSkipsPut() async throws {
        let client = NetworkClientMock()
        client.responses = [.success(profileJSON(likes: ["a"]))]
        let service = UserProfileServiceImpl(networkClient: client)

        let result = try await service.updateLikes(.add("a"))

        XCTAssertEqual(result.likes, ["a"])
        XCTAssertEqual(client.requests.map(\.httpMethod), [.get])
    }

    func testGetErrorIsPropagatedWithoutPut() async {
        let client = NetworkClientMock()
        client.responses = [.failure(NetworkClientError.httpStatusCode(500))]
        let service = UserProfileServiceImpl(networkClient: client)

        do {
            _ = try await service.updateLikes(.add("a"))
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(client.requests.count, 1)
        }
    }

    func testPutErrorIsPropagated() async {
        let client = NetworkClientMock()
        client.responses = [.success(profileJSON(likes: [])), .failure(NetworkClientError.httpStatusCode(500))]
        let service = UserProfileServiceImpl(networkClient: client)

        do {
            _ = try await service.updateLikes(.add("a"))
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(client.requests.count, 2)
        }
    }
}

final class UserOrderServiceTests: XCTestCase {

    func testUpdateNftsDoesGetThenPutAndReturnsPutResponse() async throws {
        let client = NetworkClientMock()
        client.responses = [.success(orderJSON(nfts: ["a", "b"])), .success(orderJSON(nfts: ["b"]))]
        let service = UserOrderServiceImpl(networkClient: client)

        let result = try await service.updateNfts(.remove("a"))

        XCTAssertEqual(result.nfts, ["b"])
        XCTAssertEqual(client.requests.map(\.httpMethod), [.get, .put])
        XCTAssertEqual(string(client.requests.last?.rawBody), "nfts=b")
    }

    func testUpdateNftsWithoutChangeSkipsPut() async throws {
        let client = NetworkClientMock()
        client.responses = [.success(orderJSON(nfts: ["a"]))]
        let service = UserOrderServiceImpl(networkClient: client)

        let result = try await service.updateNfts(.remove("x"))

        XCTAssertEqual(result.nfts, ["a"])
        XCTAssertEqual(client.requests.map(\.httpMethod), [.get])
    }

    func testGetErrorIsPropagatedWithoutPut() async {
        let client = NetworkClientMock()
        client.responses = [.failure(NetworkClientError.httpStatusCode(500))]
        let service = UserOrderServiceImpl(networkClient: client)

        do {
            _ = try await service.updateNfts(.add("a"))
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(client.requests.count, 1)
        }
    }

    func testPutErrorIsPropagated() async {
        let client = NetworkClientMock()
        client.responses = [.success(orderJSON(nfts: [])), .failure(NetworkClientError.httpStatusCode(500))]
        let service = UserOrderServiceImpl(networkClient: client)

        do {
            _ = try await service.updateNfts(.add("a"))
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(client.requests.count, 2)
        }
    }
}
