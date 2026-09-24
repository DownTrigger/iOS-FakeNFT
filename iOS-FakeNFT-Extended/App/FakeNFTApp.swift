import SwiftUI

@main
struct FakeNFTApp: App {
    init() {
        TabBarAppearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl()))
        }
    }
}
