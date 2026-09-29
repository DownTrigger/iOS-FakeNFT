import Foundation

@MainActor
@Observable
final class CartViewModel {
    private(set) var state: LoadingState<[Nft]> = .idle
    private(set) var sortOption: CartSortOption = .byTitle
    var alert: AlertModel?

    var items: [Nft] {
        guard case let .loaded(items) = state else {
            return []
        }
        switch sortOption {
        case .byTitle:
            return sortBy(items, keyPath: \.name)
        case .byRating:
            return sortBy(items, keyPath: \.rating, ascending: false)
        case .byPrice:
            return sortBy(items, keyPath: \.price, ascending: false)
        }
    }

    var totalPrice: Double {
        items.reduce(0) { $0 + $1.price }
    }

    func applySort(_ option: CartSortOption) {
        sortOption = option
    }

    func load(using service: CartService) async {
        state = .loading
        do {
            let items = try await service.loadCart()
            state = .loaded(items)
        } catch is CancellationError {
            state = .idle
        } catch let error as URLError where error.code == .cancelled {
            state = .idle
        } catch {
            state = .failed(error)
            alert = .retryError(title: CartLocalizedText.loadError.text) { [weak self] in
                Task { await self?.load(using: service) }
            }
        }
    }
}
