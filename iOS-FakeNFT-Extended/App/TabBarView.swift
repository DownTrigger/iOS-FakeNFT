import SwiftUI

struct TabBarView: View {
    @Environment(ServicesAssembly.self) private var services
    @State private var profileRouter = Router<ProfileRoute>()

    var body: some View {
        TabView {
            NavigationStack(path: $profileRouter.path) {
                ProfileView(userService: services.userService)
            }
            .environment(profileRouter)
            .tabItem {
                Label {
                    Text(TabLocalizedText.profile.key)
                } icon: {
                    Image(.icTabProfile)
                }
            }

            NavigationStack {
                CatalogSmokeView()
            }
                .tabItem {
                    Label {
                        Text(TabLocalizedText.catalog.key)
                    } icon: {
                        Image(.icTabCatalog)
                    }
                }

            NavigationStack {
                CartView()
            }
                .tabItem {
                    Label {
                        Text(TabLocalizedText.cart.key)
                    } icon: {
                        Image(.icTabBasket)
                    }
                }

            NavigationStack {
                StatisticsView()
            }
                .tabItem {
                    Label {
                        Text(TabLocalizedText.statistics.key)
                    } icon: {
                        Image(.icTabStatistics)
                    }
                }
        }
        .tint(Color(.fnBlue))
    }
}

#Preview {
    TabBarView()
        .environment(ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl()))
}
