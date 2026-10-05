import XCTest
@testable import iOS_FakeNFT_Extended

private actor Gate {
    private(set) var changes: [IdChange] = []
    private var continuations: [CheckedContinuation<Result<[String], Error>, Never>] = []

    func call(_ change: IdChange) async throws -> [String] {
        changes.append(change)
        let result = await withCheckedContinuation { continuations.append($0) }
        return try result.get()
    }

    func resume(_ index: Int, with result: Result<[String], Error>) {
        continuations[index].resume(returning: result)
    }
}

private actor LoadStub {
    private var results: [Result<[String], Error>]
    private(set) var count = 0

    init(_ results: [Result<[String], Error>]) {
        self.results = results
    }

    func next() throws -> [String] {
        count += 1
        return try (results.count > 1 ? results.removeFirst() : results[0]).get()
    }
}

private final class ProfileServiceStub: UserProfileService {
    let load: LoadStub
    let gate = Gate()

    init(load: [Result<[String], Error>] = [.success([])]) {
        self.load = LoadStub(load)
    }

    func loadProfile() async throws -> UserProfile {
        try await profile(likes: load.next())
    }

    func updateLikes(_ change: IdChange) async throws -> UserProfile {
        try await profile(likes: gate.call(change))
    }

    func updateProfile(name: String, description: String, avatar: String?, website: String?) async throws -> UserProfile {
        try await loadProfile()
    }

    private func profile(likes: [String]) -> UserProfile {
        UserProfile(id: "1", name: "Name", description: "Bio", website: nil, avatar: nil, nfts: [], likes: likes)
    }
}

private final class OrderServiceStub: UserOrderService {
    let load: LoadStub
    let gate = Gate()

    init(load: [Result<[String], Error>] = [.success([])]) {
        self.load = LoadStub(load)
    }

    func loadOrder() async throws -> UserOrder {
        try await UserOrder(id: "1", nfts: load.next())
    }

    func updateNfts(_ change: IdChange) async throws -> UserOrder {
        try await UserOrder(id: "1", nfts: gate.call(change))
    }

    func clearOrder() async throws -> UserOrder {
        UserOrder(id: "1", nfts: [])
    }
}

private struct StubError: Error, Equatable {}

@MainActor
final class UserStateTests: XCTestCase {

    private func makeState(
        likes: [String] = [],
        cart: [String] = []
    ) -> (UserState, ProfileServiceStub, OrderServiceStub) {
        let profile = ProfileServiceStub(load: [.success(likes)])
        let order = OrderServiceStub(load: [.success(cart)])
        return (UserState(profileService: profile, orderService: order), profile, order)
    }

    private func waitForCalls(_ count: Int, in gate: Gate, file: StaticString = #filePath, line: UInt = #line) async {
        for _ in 0..<200 {
            if await gate.changes.count >= count { return }
            try? await Task.sleep(for: .milliseconds(10))
        }
        XCTFail("Timed out waiting for \(count) calls", file: file, line: line)
    }

    private func loaded(
        likes: [String] = [],
        cart: [String] = []
    ) async throws -> (UserState, ProfileServiceStub, OrderServiceStub) {
        let result = makeState(likes: likes, cart: cart)
        try await result.0.loadIfNeeded()
        return result
    }

    func testLoadIfNeededFillsSets() async throws {
        let (state, _, _) = try await loaded(likes: ["a"], cart: ["b", "c"])

        XCTAssertTrue(state.isLoaded)
        XCTAssertEqual(state.likes, ["a"])
        XCTAssertEqual(state.cart, ["b", "c"])
        XCTAssertTrue(state.isLiked("a"))
        XCTAssertTrue(state.isInCart("b"))
        XCTAssertFalse(state.isInCart("a"))
    }

    func testSecondLoadMakesNoRequests() async throws {
        let (state, profile, order) = try await loaded(likes: ["a"])

        try await state.loadIfNeeded()

        let profileCount = await profile.load.count
        let orderCount = await order.load.count
        XCTAssertEqual(profileCount, 1)
        XCTAssertEqual(orderCount, 1)
    }

    func testLoadErrorIsPropagatedAndNextCallRetries() async throws {
        let profile = ProfileServiceStub(load: [.failure(StubError()), .success(["a"])])
        let order = OrderServiceStub()
        let state = UserState(profileService: profile, orderService: order)

        do {
            try await state.loadIfNeeded()
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is StubError)
        }
        XCTAssertFalse(state.isLoaded)

        try await state.loadIfNeeded()

        XCTAssertTrue(state.isLoaded)
        XCTAssertEqual(state.likes, ["a"])
    }

    func testLoadKeepsPendingToggleMadeBeforeLoad() async throws {
        let (state, profile, _) = makeState(likes: ["x"])

        let task = Task { try await state.toggleLike("a") }
        await waitForCalls(1, in: profile.gate)

        try await state.loadIfNeeded()

        XCTAssertEqual(state.likes, ["x", "a"])
        XCTAssertTrue(state.isLikePending("a"))

        await profile.gate.resume(0, with: .success(["x", "a"]))
        try await task.value
        XCTAssertEqual(state.likes, ["x", "a"])
    }

    func testToggleLikeIsOptimisticUntilResponse() async throws {
        let (state, profile, _) = try await loaded()

        let task = Task { try await state.toggleLike("a") }
        await waitForCalls(1, in: profile.gate)

        XCTAssertTrue(state.isLiked("a"))
        XCTAssertTrue(state.isLikePending("a"))

        await profile.gate.resume(0, with: .success(["a", "z"]))
        try await task.value

        XCTAssertEqual(state.likes, ["a", "z"])
        XCTAssertFalse(state.isLikePending("a"))
        let changes = await profile.gate.changes
        XCTAssertEqual(changes, [.add("a")])
    }

    func testToggleLikeOnLikedSendsRemove() async throws {
        let (state, profile, _) = try await loaded(likes: ["a"])

        let task = Task { try await state.toggleLike("a") }
        await waitForCalls(1, in: profile.gate)
        XCTAssertFalse(state.isLiked("a"))

        await profile.gate.resume(0, with: .success([]))
        try await task.value

        XCTAssertTrue(state.likes.isEmpty)
        let changes = await profile.gate.changes
        XCTAssertEqual(changes, [.remove("a")])
    }

    func testToggleLikeErrorRollsBackOnlyThatIdAndRethrows() async throws {
        let (state, profile, _) = try await loaded(likes: ["x"])

        let first = Task { try await state.toggleLike("a") }
        await waitForCalls(1, in: profile.gate)
        let second = Task { try await state.toggleLike("b") }
        await Task.yield()

        await profile.gate.resume(0, with: .failure(StubError()))
        do {
            try await first.value
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is StubError)
        }

        XCTAssertFalse(state.isLiked("a"))
        XCTAssertFalse(state.isLikePending("a"))
        XCTAssertTrue(state.isLiked("b"))
        XCTAssertTrue(state.isLiked("x"))

        await waitForCalls(2, in: profile.gate)
        await profile.gate.resume(1, with: .success(["x", "b"]))
        try await second.value
        XCTAssertEqual(state.likes, ["x", "b"])
    }

    func testRepeatedTapOnPendingIdIsIgnored() async throws {
        let (state, profile, _) = try await loaded()

        let first = Task { try await state.toggleLike("a") }
        await waitForCalls(1, in: profile.gate)

        try await state.toggleLike("a")

        XCTAssertTrue(state.isLiked("a"))
        await profile.gate.resume(0, with: .success(["a"]))
        try await first.value
        let changes = await profile.gate.changes
        XCTAssertEqual(changes, [.add("a")])
    }

    func testSecondIdRequestStartsAfterFirstFinishesAndKeepsItsPendingState() async throws {
        let (state, profile, _) = try await loaded()

        let first = Task { try await state.toggleLike("a") }
        await waitForCalls(1, in: profile.gate)
        let second = Task { try await state.toggleLike("b") }
        for _ in 0..<20 { await Task.yield() }

        let callsBefore = await profile.gate.changes.count
        XCTAssertEqual(callsBefore, 1)
        XCTAssertTrue(state.isLiked("b"))

        await profile.gate.resume(0, with: .success(["a"]))
        try await first.value

        XCTAssertEqual(state.likes, ["a", "b"])
        XCTAssertTrue(state.isLikePending("b"))

        await waitForCalls(2, in: profile.gate)
        await profile.gate.resume(1, with: .success(["a", "b"]))
        try await second.value

        XCTAssertEqual(state.likes, ["a", "b"])
        XCTAssertFalse(state.isLikePending("b"))
    }

    func testToggleCartSuccess() async throws {
        let (state, _, order) = try await loaded()

        let task = Task { try await state.toggleCart("n") }
        await waitForCalls(1, in: order.gate)

        XCTAssertTrue(state.isInCart("n"))
        XCTAssertTrue(state.isCartPending("n"))

        await order.gate.resume(0, with: .success(["n"]))
        try await task.value

        XCTAssertEqual(state.cart, ["n"])
        XCTAssertFalse(state.isCartPending("n"))
    }

    func testToggleCartErrorRollsBack() async throws {
        let (state, _, order) = try await loaded(cart: ["n"])

        let task = Task { try await state.toggleCart("n") }
        await waitForCalls(1, in: order.gate)
        XCTAssertFalse(state.isInCart("n"))

        await order.gate.resume(0, with: .failure(StubError()))
        do {
            try await task.value
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is StubError)
        }

        XCTAssertTrue(state.isInCart("n"))
        XCTAssertFalse(state.isCartPending("n"))
    }
}
