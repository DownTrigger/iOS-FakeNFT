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

    var userService: UserServiceProtocol {
        UserServiceImpl(
            networkClient: networkClient
        )
    }

    var profileService: ProfileService {
        ProfileServiceImpl(
            networkClient: networkClient
        )
    }

    func isLiked(nftID: String) async -> Bool {
        await likesStorage.isLiked(nftID: nftID)
    }

    // TODO: временный код, заменить на данные модуля авторизации
    func loadCurrentUserLikes() async {
        do {
            let profile = try await profileService.loadProfile()

            await likesStorage.saveLikes(profile.likes)
        } catch {
            print("Failed to load current user likes:", error)
        }
    }
}
