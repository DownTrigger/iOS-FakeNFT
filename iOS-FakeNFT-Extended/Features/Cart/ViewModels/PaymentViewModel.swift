import Foundation

@MainActor
@Observable
final class PaymentViewModel {
    private(set) var state: LoadingState<[Currency]> = .idle
    private(set) var selectedCurrency: Currency?
    private(set) var isPaying = false
    private(set) var isPaid = false
    var alert: AlertModel?

    private var isPaymentConfirmed = false

    var currencies: [Currency] {
        guard case let .loaded(currencies) = state else {
            return []
        }
        return currencies
    }

    var canPay: Bool {
        selectedCurrency != nil && !isPaying && !isPaid
    }

    func load(using service: PaymentService) async {
        state = .loading
        do {
            state = .loaded(try await service.loadCurrencies())
        } catch {
            guard !error.isCancellation else {
                state = .idle
                return
            }
            state = .failed(error)
            alert = .retryError(title: CartLocalizedText.currenciesLoadError.resource) { [weak self] in
                Task { await self?.load(using: service) }
            }
        }
    }

    func select(_ currency: Currency) {
        guard !isPaying, !isPaymentConfirmed else {
            return
        }
        selectedCurrency = currency
    }

    func pay(using paymentService: PaymentService, cartService: CartService) async {
        guard let currency = selectedCurrency, !isPaying else {
            return
        }
        isPaying = true
        defer { isPaying = false }

        do {
            if !isPaymentConfirmed {
                try await paymentService.pay(currencyId: currency.id)
                isPaymentConfirmed = true
            }
            try await cartService.clear()
            isPaid = true
        } catch {
            guard !error.isCancellation else { return }
            alert = .retryError(title: CartLocalizedText.paymentError.resource) { [weak self] in
                Task { await self?.pay(using: paymentService, cartService: cartService) }
            }
        }
    }
}
