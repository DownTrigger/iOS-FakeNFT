import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ProfileView()
            }
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
