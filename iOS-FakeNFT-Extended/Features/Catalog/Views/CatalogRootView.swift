import SwiftUI

enum CatalogRoute: Hashable {}

struct CatalogRootView: View {
    @Environment(ServicesAssembly.self) private var services
    @State private var router = Router<CatalogRoute>()

    var body: some View {
        NavigationStack(path: $router.path) {
            CatalogView(service: services.collectionsService)
        }
        .environment(router)
    }
}

#Preview {
    CatalogRootView()
        .environment(ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl()))
}
