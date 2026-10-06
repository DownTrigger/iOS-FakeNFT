import Foundation

@Observable
@MainActor
final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    private let likesStorage: LikesStorage

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage,
        likesStorage: LikesStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
        self.likesStorage = likesStorage
    }

    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }

    var collectionsService: CollectionsService {
        CollectionsServiceImpl(networkClient: networkClient)
    }

    var userService: UserService {
        UserServiceImpl(networkClient: networkClient)
    }

    var usersService: UserServiceProtocol {
        UsersServiceImpl(networkClient: networkClient)
    }

    var userDefaultsService: UserDefaultsService {
        UserDefaultsServiceImpl()
    }

    var userProfileService: UserProfileService {
        UserProfileServiceImpl(
            networkClient: networkClient
        )
    }

	var userOrderService: UserOrderService {
        UserOrderServiceImpl(networkClient: networkClient)
	}

    var cartService: CartService {
        CartServiceImpl(
            orderService: userOrderService,
            nftService: nftService
        )
    }

    var paymentService: PaymentService {
        PaymentServiceImpl(networkClient: networkClient)
    }

    func isLiked(nftID: String) async -> Bool {
        await likesStorage.isLiked(nftID: nftID)
    }

    func isInCart(nftID: String) async -> Bool {
        // TODO: Добавить обработку из эпика Корзина, временно для всех false
        false
    }

    // TODO: временный код, заменить на данные модуля авторизации
    func loadCurrentUserLikes() async {
        do {
            let profile = try await userProfileService.loadProfile()

            await likesStorage.saveLikes(profile.likes)
        } catch {
            print("Failed to load current user likes:", error)
        }
    }
}
