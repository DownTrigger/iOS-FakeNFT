import SwiftUI

private enum TabBarItem {
    case profile
    case catalog
    case cart
    case statistics
}

struct TabBarView: View {
    @State private var selectedTab: TabBarItem = .profile

    @State private var statisticsViewModel = StatisticsViewModel(
        userService: UserServiceImpl(
            networkClient: DefaultNetworkClient()
        )
    )

    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileView()
                .tabItem {
                    Label {
                        Text(TabLocalizedText.profile.key)
                    } icon: {
                        Image(.icTabProfile)
                    }
                }
                .tag(TabBarItem.profile)

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
                .tag(TabBarItem.catalog)

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
                .tag(TabBarItem.cart)

            NavigationStack {
                StatisticsView(viewModel: statisticsViewModel)
            }
                .tabItem {
                    Label {
                        Text(TabLocalizedText.statistics.key)
                    } icon: {
                        Image(.icTabStatistics)
                    }
                }
                .tag(TabBarItem.statistics)
        }
        .tint(Color(.fnBlue))
            .onChange(of: selectedTab) { oldValue, newValue in
                if oldValue == .statistics && newValue != .statistics {
                    statisticsViewModel.resetCache()
                }
            }
    }
}

#Preview {
    TabBarView()
        .environment(ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl()))
}
