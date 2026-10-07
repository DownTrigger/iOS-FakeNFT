import SwiftUI

private enum TabBarItem {
    case profile
    case catalog
    case cart
    case statistics
}

struct TabBarView: View {
    @State private var selectedTab: TabBarItem = .profile

    var body: some View {
        TabView(selection: $selectedTab) {
            ProfileRootView()
            .tabItem {
                Label {
                    Text(TabLocalizedText.profile.key)
                } icon: {
                    Image(.icTabProfile)
                }
            }
            .tag(TabBarItem.profile)

            CatalogRootView()
                .tabItem {
                    Label {
                        Text(TabLocalizedText.catalog.key)
                    } icon: {
                        Image(.icTabCatalog)
                    }
                }
            .tag(TabBarItem.catalog)

            CartRootView()
            .tabItem {
                Label {
                    Text(TabLocalizedText.cart.key)
                } icon: {
                    Image(.icTabBasket)
                }
            }
            .tag(TabBarItem.cart)

            NavigationStack {
                StatisticsView(isActive: selectedTab == .statistics)
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
