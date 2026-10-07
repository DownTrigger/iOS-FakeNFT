import SwiftUI

struct ProfileRootView: View {
    @Environment(ServicesAssembly.self) private var services
    @Environment(UserState.self) private var userState
    @State private var router = Router<ProfileRoute>()

    var body: some View {
        NavigationStack(path: $router.path) {
            ProfileView(profileService: services.userProfileService, userState: userState)
        }
        .environment(router)
    }
}

#Preview {
    let services = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl())
    ProfileRootView()
        .environment(services)
        .environment(UserState(profileService: services.userProfileService, orderService: services.userOrderService))
}
