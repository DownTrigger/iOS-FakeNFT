import Foundation

@Observable
@MainActor
final class ServicesAssembly {

    private let networkClient: NetworkClient
    private let nftStorage: NftStorage

    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
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

    var usersService: UserServiceProtocol {
        UsersServiceImpl(networkClient: networkClient)
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
}
