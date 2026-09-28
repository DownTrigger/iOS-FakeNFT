import SwiftUI

struct CartView: View {
    @Environment(ServicesAssembly.self) private var services
    @State private var viewModel = CartViewModel()
    @State private var isSortSheetPresented = false

    var body: some View {
        ZStack {
            content
                .background(Color(.fnBackground))
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationSortButton {
                    withAnimation {
                        isSortSheetPresented = true
                    }
                }
            }
        }
        .task { await viewModel.load(using: services.cartService) }
        .appAlert(item: $viewModel.alert)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            AppLoadingView()
        case .loaded(let items) where items.isEmpty:
            EmptyStateView(message: CartLocalizedText.empty.text)
        case .loaded(let items):
            cartList(items)
        case .failed:
            Color.clear
        }
    }

    private func cartList(_ items: [CartNft]) -> some View {
        VStack(spacing: 0) {
            List(items) { nft in
                CartItemCell(nft: nft) {}
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)

            CartSummaryPanel(count: items.count, totalPrice: viewModel.totalPrice) {}
        }
    }
}

#Preview {
    NavigationStack {
        CartView()
    }
    .environment(ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl()))
}
