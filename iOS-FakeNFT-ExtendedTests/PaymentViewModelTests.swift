import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class PaymentViewModelTests: XCTestCase {

    func testLoadCurrencies() async {
        // Given
        let viewModel = PaymentViewModel()

        // When
        await viewModel.load(using: PaymentServiceStub())

        // Then
        XCTAssertEqual(viewModel.currencies.map(\.id), ["1", "2"])
        XCTAssertFalse(viewModel.canPay)
    }

    func testLoadCurrenciesFailureShowsAlert() async {
        // Given
        let viewModel = PaymentViewModel()

        // When
        await viewModel.load(using: PaymentServiceStub(loadError: NetworkClientError.urlSessionError))

        // Then
        XCTAssertTrue(viewModel.currencies.isEmpty)
        XCTAssertNotNil(viewModel.alert)
    }

    func testSelectCurrencyEnablesPayment() async {
        // Given
        let viewModel = PaymentViewModel()
        await viewModel.load(using: PaymentServiceStub())

        // When
        viewModel.select(.stub(id: "2"))

        // Then
        XCTAssertEqual(viewModel.selectedCurrency?.id, "2")
        XCTAssertTrue(viewModel.canPay)
    }

    func testPaySuccessClearsCart() async {
        // Given
        let paymentService = PaymentServiceStub()
        let cartService = OrderCartServiceStub()
        let viewModel = PaymentViewModel()
        viewModel.select(.stub(id: "2"))

        // When
        await viewModel.pay(using: paymentService, cartService: cartService)

        // Then
        let paidWith = await paymentService.paidCurrencyIds
        let clearCount = await cartService.clearCount
        XCTAssertEqual(paidWith, ["2"])
        XCTAssertEqual(clearCount, 1)
        XCTAssertTrue(viewModel.isPaid)
        XCTAssertNil(viewModel.alert)
    }

    func testPayFailureShowsAlertAndKeepsCart() async {
        // Given
        let paymentService = PaymentServiceStub(payError: PaymentError.declined)
        let cartService = OrderCartServiceStub()
        let viewModel = PaymentViewModel()
        viewModel.select(.stub(id: "2"))

        // When
        await viewModel.pay(using: paymentService, cartService: cartService)

        // Then
        let clearCount = await cartService.clearCount
        XCTAssertEqual(clearCount, 0)
        XCTAssertFalse(viewModel.isPaid)
        XCTAssertFalse(viewModel.isPaying)
        XCTAssertNotNil(viewModel.alert)
    }

    func testPayWithoutSelectedCurrencyDoesNothing() async {
        // Given
        let paymentService = PaymentServiceStub()
        let viewModel = PaymentViewModel()

        // When
        await viewModel.pay(using: paymentService, cartService: OrderCartServiceStub())

        // Then
        let paidWith = await paymentService.paidCurrencyIds
        XCTAssertTrue(paidWith.isEmpty)
        XCTAssertFalse(viewModel.isPaid)
    }

    func testCurrencyDisplayTitleReplacesUnderscores() {
        XCTAssertEqual(Currency(id: "0", title: "Shiba_Inu", name: "SHIB", image: nil).displayTitle, "Shiba Inu")
    }
}

private actor PaymentServiceStub: PaymentService {
    let loadError: Error?
    let payError: Error?
    private(set) var paidCurrencyIds: [String] = []

    init(loadError: Error? = nil, payError: Error? = nil) {
        self.loadError = loadError
        self.payError = payError
    }

    func loadCurrencies() async throws -> [Currency] {
        if let loadError {
            throw loadError
        }
        return [.stub(id: "1"), .stub(id: "2")]
    }

    func pay(currencyId: String) async throws {
        paidCurrencyIds.append(currencyId)
        if let payError {
            throw payError
        }
    }
}

private actor OrderCartServiceStub: CartService {
    private(set) var clearCount = 0

    func loadCart() async throws -> [Nft] {
        []
    }

    func remove(nftId: String) async throws {}

    func clear() async throws {
        clearCount += 1
    }
}

private extension Currency {
    static func stub(id: String) -> Currency {
        Currency(id: id, title: "Coin \(id)", name: "C\(id)", image: nil)
    }
}
