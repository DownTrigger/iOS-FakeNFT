import SwiftUI

@main
struct FakeNFTApp: App {
    @State private var services: ServicesAssembly
    @State private var userState: UserState

    init() {
        TabBarAppearance.configure()
        let services = ServicesAssembly(
                                        networkClient: DefaultNetworkClient(),
                                        nftStorage: NftStorageImpl(),
                                        likesStorage: LikesStorageImpl()
                                        )
        
        _services = State(initialValue: services)
        
        _userState = State(initialValue: UserState(
            profileService: services.userProfileService,
            orderService: services.userOrderService
        ))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(services)
                .environment(userState)
        }
    }
}
