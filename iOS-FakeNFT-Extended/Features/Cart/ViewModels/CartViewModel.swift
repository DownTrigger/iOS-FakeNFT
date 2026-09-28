import Foundation

@MainActor
@Observable
final class CartViewModel {
    private(set) var state: LoadingState<[CartNft]> = .idle
    var alert: AlertModel?

    var items: [CartNft] {
        if case let .loaded(items) = state {
            return items
        }
        return []
    }

    var totalPrice: Double {
        items.reduce(0) { $0 + $1.price }
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
