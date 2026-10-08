import SwiftUI

struct NftDetailView: View {
    @Environment(ServicesAssembly.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: NftDetailViewModel
    @State private var currentIndex = 0

    init(nftId: String) {
        _viewModel = State(initialValue: NftDetailViewModel(nftId: nftId))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            content
            closeButton
        }
        .task { await load() }
        .presentationCornerRadius(10)
        .appAlert(item: $viewModel.alert)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            AppLoadingView()
        case let .loaded(nft):
            gallery(for: nft.images)
        case .failed:
            if viewModel.alert == nil {
                ErrorStateView(message: CatalogLocalizedText.loadError.key) {
                    Task { await load() }
                }
            }
        }
    }

    @ViewBuilder
    private func gallery(for images: [URL]) -> some View {
        VStack(spacing: 16) {
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, url in
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        AppLoadingView()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            LinePageIndicator(count: images.count, selected: currentIndex)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
        }
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(.icClose)
                .foregroundStyle(Color(.fnText))
                .contentShape(Rectangle())
        }
        .padding(.top, 30)
        .padding(.trailing, 16)
    }

    private func load() async {
        await viewModel.load(using: services.nftService)
    }
}

private struct LinePageIndicator: View {
    let count: Int
    let selected: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == selected ? Color(.fnText) : Color(.fnLightGray))
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            NftDetailView(nftId: "7773e33c-ec15-4230-a102-92426a3a6d5a")
                .environment(
                    ServicesAssembly(
                        networkClient: DefaultNetworkClient(),
                        nftStorage: NftStorageImpl()
                    )
                )
        }
}
