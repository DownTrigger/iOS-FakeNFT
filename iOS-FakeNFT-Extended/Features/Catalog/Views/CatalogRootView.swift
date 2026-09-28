import SwiftUI

enum CatalogRoute: Hashable {
    case collection(NftCollection)
    case website(URL)
}

struct CatalogRootView: View {
    @Environment(ServicesAssembly.self) private var services
    @State private var router = Router<CatalogRoute>()

    var body: some View {
        NavigationStack(path: $router.path) {
            CatalogView(service: services.collectionsService)
                .navigationDestination(for: CatalogRoute.self) { route in
                    destination(for: route)
                }
        }
        .tint(Color(.fnText))
        .environment(router)
    }

    @ViewBuilder
    private func destination(for route: CatalogRoute) -> some View {
        switch route {
        case .collection(let collection):
            CollectionView(collection: collection, nftService: services.nftService)
        case .website(let url):
            WebViewScreen(url: url)
        }
    }
}

#Preview {
    CatalogRootView()
        .environment(ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl()))
}
