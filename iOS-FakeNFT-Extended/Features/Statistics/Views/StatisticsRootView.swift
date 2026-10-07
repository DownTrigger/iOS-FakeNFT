import SwiftUI

enum StatisticsRoute: Hashable {
    case user(UserStatisticItem)
    case nftCollection([String])
    case website(URL)
}

struct StatisticsRootView: View {
    @Environment(ServicesAssembly.self) private var services
    @Environment(UserState.self) private var userState
    @State private var router = Router<StatisticsRoute>()

    var body: some View {
        NavigationStack(path: $router.path) {
            StatisticsView(service: services.usersService)
                .navigationDestination(for: StatisticsRoute.self) { route in
                    destination(for: route)
                }
        }
        .tint(Color(.fnText))
        .environment(router)
    }

    @ViewBuilder
    private func destination(for route: StatisticsRoute) -> some View {
        switch route {
        case .user(let item):
            UserStatisticDetailView(statistic: item)
        case .nftCollection(let ids):
            NFTCollectionView(nfts: ids, nftService: services.nftService, userState: userState)
        case .website(let url):
            WebViewScreen(url: url)
        }
    }
}

#Preview {
    let services = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl())
    StatisticsRootView()
        .environment(services)
        .environment(UserState(profileService: services.userProfileService, orderService: services.userOrderService))
}
