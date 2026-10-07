import Foundation

@MainActor
@Observable
final class NftDetailViewModel {
    private let nftId: String

    private(set) var state: LoadingState<Nft> = .idle
    var alert: AlertModel?

    init(nftId: String) {
        self.nftId = nftId
    }

    func load(using service: NftService) async {
        state = .loading
        do {
            let nft = try await service.loadNft(id: nftId)
            state = .loaded(nft)
        } catch {
            guard !error.isCancellation else {
                state = .idle
                return
            }
            state = .failed(error)
            alert = .retryError(title: CatalogLocalizedText.loadError.resource) { [weak self] in
                Task { await self?.load(using: service) }
            }
        }
    }
}
