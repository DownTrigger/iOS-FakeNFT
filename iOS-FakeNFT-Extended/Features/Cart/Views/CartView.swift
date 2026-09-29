import SwiftUI

struct CartView: View {
    private static let sortOptionKey = "cart.sortOption"

    @Environment(ServicesAssembly.self) private var services
    @State private var viewModel = CartViewModel()
    @State private var isSortSheetPresented = false
    @AppStorage(Self.sortOptionKey) private var sortOption: CartSortOption = .byTitle

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
        .sortSheet(
            isPresented: $isSortSheetPresented,
            options: [CartSortOption.byPrice, .byRating, .byTitle]
        ) { option in
            sortOption = option
        }
        .task(id: sortOption) { viewModel.applySort(sortOption) }
        .task { await viewModel.load(using: services.cartService) }
        .appAlert(item: $viewModel.alert)
        .fullScreenCover(isPresented: isDeleteConfirmationPresented) {
            if let nft = viewModel.nftToDelete {
                CartDeleteConfirmationView(
                    nft: nft,
                    onDelete: { viewModel.cancelDelete() },
                    onCancel: { viewModel.cancelDelete() }
                )
                .presentationBackground(.ultraThinMaterial)
            }
        }
    }

    private var isDeleteConfirmationPresented: Binding<Bool> {
        Binding(
            get: { viewModel.nftToDelete != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.cancelDelete()
                }
            }
        )
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            AppLoadingView()
        case .loaded(let items) where items.isEmpty:
            EmptyStateView(message: CartLocalizedText.empty.text)
        case .loaded:
            cartList(viewModel.items)
        case .failed:
            Color.clear
        }
    }

    private func cartList(_ items: [Nft]) -> some View {
        VStack(spacing: 0) {
            List(items, id: \.id) { nft in
                CartItemCell(nft: nft) {
                    viewModel.requestDelete(nft)
                }
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
