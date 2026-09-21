import SwiftUI

@MainActor
@Observable
final class NftDetailSmokeViewModel {
    private static let testNftId = "7773e33c-ec15-4230-a102-92426a3a6d5a"

    private(set) var state: LoadingState<Nft> = .idle

    func load(using service: NftService) async {
        state = .loading
        do {
            let nft = try await service.loadNft(id: Self.testNftId)
            state = .loaded(nft)
        } catch {
            state = .failed(error)
        }
    }
}

struct NftDetailSmokeView: View {
    @Environment(ServicesAssembly.self) private var services
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = NftDetailSmokeViewModel()
    @State private var currentIndex = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            content
            closeButton
        }
        .task { await load() }
        .presentationCornerRadius(10)
        .alert("Error.title", isPresented: isErrorPresented) {
            Button("Error.repeat") {
                Task { await load() }
            }
        } message: {
            Text(errorMessageKey)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            AppLoadingView()
        case let .loaded(nft):
            gallery(for: nft.images)
        case .failed:
            Color.clear
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

    private var isErrorPresented: Binding<Bool> {
        Binding(
            get: {
                if case .failed = viewModel.state { return true }
                return false
            },
            set: { _ in }
        )
    }

    private var errorMessageKey: LocalizedStringKey {
        if case let .failed(error) = viewModel.state, error is NetworkClientError {
            return "Error.network"
        }
        return "Error.unknown"
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
            NftDetailSmokeView()
                .environment(
                    ServicesAssembly(
                        networkClient: DefaultNetworkClient(),
                        nftStorage: NftStorageImpl()
                    )
                )
        }
}
