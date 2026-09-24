import SwiftUI

enum CatalogRoute: Hashable {}

struct CatalogRootView: View {
    @State private var router = Router<CatalogRoute>()

    var body: some View {
        NavigationStack(path: $router.path) {
            CatalogView()
        }
        .environment(router)
    }
}

#Preview {
    CatalogRootView()
}
