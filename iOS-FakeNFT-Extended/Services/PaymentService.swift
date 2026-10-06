import Foundation

enum PaymentError: Error {
    case declined
}

protocol PaymentService: Sendable {
    func loadCurrencies() async throws -> [Currency]
    func pay(currencyId: String) async throws
}

actor PaymentServiceImpl: PaymentService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCurrencies() async throws -> [Currency] {
        try await networkClient.send(request: CurrenciesRequest())
    }

    func pay(currencyId: String) async throws {
        let result: PaymentResult = try await networkClient.send(request: PaymentRequest(currencyId: currencyId))
        guard result.success else {
            throw PaymentError.declined
        }
    }
}
