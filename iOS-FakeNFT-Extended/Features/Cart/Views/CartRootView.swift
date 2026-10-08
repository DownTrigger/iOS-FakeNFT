import SwiftUI

enum CartRoute: Hashable {
    case payment
    case agreement(URL)
    case success
}

struct CartRootView: View {
    @State private var router = Router<CartRoute>()

    var body: some View {
        NavigationStack(path: $router.path) {
            CartView()
                .navigationDestination(for: CartRoute.self) { route in
                    destination(for: route)
                }
        }
        .tint(Color(.fnText))
        .environment(router)
    }

    @ViewBuilder
    private func destination(for route: CartRoute) -> some View {
        switch route {
        case .payment:
            PaymentView()
        case .agreement(let url):
            WebViewScreen(url: url)
        case .success:
            PaymentSuccessView()
        }
    }
}

#Preview {
    let services = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl()
    )

    CartRootView()
        .environment(services)
        .environment(UserState(profileService: services.userProfileService, orderService: services.userOrderService))
}
