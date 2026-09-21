import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            CatalogSmokeView()
                .tabItem {
                    Label {
                        Text(NSLocalizedString("Tab.catalog", comment: ""))
                    } icon: {
                        Image(.icTabCatalog)
                    }
                }
                .backgroundStyle(.background)
        }
        .tint(Color(.fnBlue))
    }
}
