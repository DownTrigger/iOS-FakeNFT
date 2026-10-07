import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            ProfileRootView()
                .tabItem {
                    Label {
                        Text(TabLocalizedText.profile.key)
                    } icon: {
                        Image(.icTabProfile)
                    }
                }

            CatalogRootView()
                .tabItem {
                    Label {
                        Text(TabLocalizedText.catalog.key)
                    } icon: {
                        Image(.icTabCatalog)
                    }
                }

            CartRootView()
                .tabItem {
                    Label {
                        Text(TabLocalizedText.cart.key)
                    } icon: {
                        Image(.icTabBasket)
                    }
                }

            StatisticsRootView()
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
    let services = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl()
    )
    TabBarView()
        .environment(services)
        .environment(UserState(profileService: services.userProfileService, orderService: services.userOrderService))
}
