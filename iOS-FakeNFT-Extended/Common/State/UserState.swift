import Foundation

@MainActor
@Observable
final class UserState {

    private struct Resource {
        var visible: Set<String> = []
        var confirmed: Set<String> = []
        var pending: [String: Bool] = [:]
        var tail: Task<Void, Error>?
    }

    private let profileService: UserProfileService
    private let orderService: UserOrderService

    private var likesResource = Resource()
    private var cartResource = Resource()
    private var loadTask: Task<Void, Error>?

    private(set) var isLoaded = false

    var likes: Set<String> { likesResource.visible }
    var cart: Set<String> { cartResource.visible }

    init(profileService: UserProfileService, orderService: UserOrderService) {
        self.profileService = profileService
        self.orderService = orderService
    }

    func isLiked(_ id: String) -> Bool {
        likesResource.visible.contains(id)
    }

    func isInCart(_ id: String) -> Bool {
        cartResource.visible.contains(id)
    }

    func isLikePending(_ id: String) -> Bool {
        likesResource.pending[id] != nil
    }

    func isCartPending(_ id: String) -> Bool {
        cartResource.pending[id] != nil
    }

    func loadIfNeeded() async throws {
        if isLoaded { return }
        if let loadTask {
            try await loadTask.value
            return
        }
        let profileService = profileService
        let orderService = orderService
        let task = Task<Void, Error> {
            do {
                async let profile = profileService.loadProfile()
                async let order = orderService.loadOrder()
                let (likes, cart) = try await (Set(profile.likes), Set(order.nfts))
                likesResource.confirmed = likes
                likesResource.visible = Self.applying(likesResource.pending, to: likes)
                cartResource.confirmed = cart
                cartResource.visible = Self.applying(cartResource.pending, to: cart)
                isLoaded = true
                loadTask = nil
            } catch {
                loadTask = nil
                throw error
            }
        }
        loadTask = task
        try await task.value
    }

    func toggleLike(_ id: String) async throws {
        let service = profileService
        try await toggle(id, in: \.likesResource) { change in
            try await service.updateLikes(change).likes
        }
    }

    func toggleCart(_ id: String) async throws {
        let service = orderService
        try await toggle(id, in: \.cartResource) { change in
            try await service.updateNfts(change).nfts
        }
    }

    private func toggle(
        _ id: String,
        in keyPath: ReferenceWritableKeyPath<UserState, Resource>,
        send: @escaping @Sendable (IdChange) async throws -> [String]
    ) async throws {
        guard self[keyPath: keyPath].pending[id] == nil else { return }

        let shouldContain = !self[keyPath: keyPath].visible.contains(id)
        let change: IdChange = shouldContain ? .add(id) : .remove(id)
        self[keyPath: keyPath].visible = Self.set(self[keyPath: keyPath].visible, id: id, contains: shouldContain)
        self[keyPath: keyPath].pending[id] = shouldContain

        let previous = self[keyPath: keyPath].tail
        let task = Task<Void, Error> {
            _ = await previous?.result
            do {
                let confirmed = Set(try await send(change))
                var resource = self[keyPath: keyPath]
                resource.pending[id] = nil
                resource.confirmed = confirmed
                resource.visible = Self.applying(resource.pending, to: confirmed)
                self[keyPath: keyPath] = resource
            } catch {
                var resource = self[keyPath: keyPath]
                resource.pending[id] = nil
                resource.visible = Self.set(resource.visible, id: id, contains: resource.confirmed.contains(id))
                self[keyPath: keyPath] = resource
                throw error
            }
        }
        self[keyPath: keyPath].tail = task
        try await task.value
    }

    private static func applying(_ pending: [String: Bool], to ids: Set<String>) -> Set<String> {
        pending.reduce(ids) { set($0, id: $1.key, contains: $1.value) }
    }

    private static func set(_ ids: Set<String>, id: String, contains: Bool) -> Set<String> {
        var ids = ids
        if contains {
            ids.insert(id)
        } else {
            ids.remove(id)
        }
        return ids
    }
}
