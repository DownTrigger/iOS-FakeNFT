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

    func testPayCallsPaymentBeforeClearingCart() async {
        // Given
        let log = CallLog()
        let viewModel = PaymentViewModel()
        viewModel.select(.stub(id: "1"))

        // When
        await viewModel.pay(using: PaymentServiceStub(log: log), cartService: OrderCartServiceStub(log: log))

        // Then
        let calls = await log.calls
        XCTAssertEqual(calls, ["pay", "clear"])
        XCTAssertTrue(viewModel.isPaid)
    }

    func testRepeatedPayTapPaysOnce() async {
        // Given
        let paymentService = PaymentServiceStub()
        let cartService = OrderCartServiceStub()
        let viewModel = PaymentViewModel()
        viewModel.select(.stub(id: "1"))

        // When
        async let first: Void = viewModel.pay(using: paymentService, cartService: cartService)
        async let second: Void = viewModel.pay(using: paymentService, cartService: cartService)
        _ = await (first, second)

        // Then
        let paidWith = await paymentService.paidCurrencyIds
        XCTAssertEqual(paidWith, ["1"])
    }

    func testClearFailureRetryDoesNotPayTwiceAndLocksCurrency() async {
        // Given
        let paymentService = PaymentServiceStub()
        let cartService = OrderCartServiceStub(clearErrors: [NetworkClientError.urlSessionError])
        let viewModel = PaymentViewModel()
        viewModel.select(.stub(id: "1"))
        await viewModel.pay(using: paymentService, cartService: cartService)
        XCTAssertNotNil(viewModel.alert)
        XCTAssertFalse(viewModel.isPaid)

        // When
        viewModel.select(.stub(id: "2"))
        await viewModel.pay(using: paymentService, cartService: cartService)

        // Then
        let paidWith = await paymentService.paidCurrencyIds
        let clearCount = await cartService.clearCount
        XCTAssertEqual(paidWith, ["1"])
        XCTAssertEqual(clearCount, 2)
        XCTAssertEqual(viewModel.selectedCurrency?.id, "1")
        XCTAssertTrue(viewModel.isPaid)
    }

    func testCurrencyDecodesImageURLFromImageKey() throws {
        // Given
        let json = Data(#"{"id":"1","title":"Bitcoin","name":"BTC","image":"https://example.com/btc.png"}"#.utf8)

        // When
        let currency = try JSONDecoder().decode(Currency.self, from: json)

        // Then
        XCTAssertEqual(currency.imageURL?.absoluteString, "https://example.com/btc.png")
    }

    func testCurrencyDisplayTitleReplacesUnderscores() {
        XCTAssertEqual(Currency(id: "0", title: "Shiba_Inu", name: "SHIB", imageURL: nil).displayTitle, "Shiba Inu")
    }
}

private actor CallLog {
    private(set) var calls: [String] = []

    func append(_ call: String) {
        calls.append(call)
    }
}

private actor PaymentServiceStub: PaymentService {
    let loadError: Error?
    let payError: Error?
    let log: CallLog?
    private(set) var paidCurrencyIds: [String] = []

    init(loadError: Error? = nil, payError: Error? = nil, log: CallLog? = nil) {
        self.loadError = loadError
        self.payError = payError
        self.log = log
    }

    func loadCurrencies() async throws -> [Currency] {
        if let loadError {
            throw loadError
        }
        return [.stub(id: "1"), .stub(id: "2")]
    }

    func pay(currencyId: String) async throws {
        paidCurrencyIds.append(currencyId)
        await log?.append("pay")
        if let payError {
            throw payError
        }
    }
}

private actor OrderCartServiceStub: CartService {
    private let log: CallLog?
    private var clearErrors: [Error]
    private(set) var clearCount = 0

    init(log: CallLog? = nil, clearErrors: [Error] = []) {
        self.log = log
        self.clearErrors = clearErrors
    }

    func loadCart() async throws -> [Nft] {
        []
    }

    func remove(nftId: String) async throws {}

    func clear() async throws {
        clearCount += 1
        await log?.append("clear")
        if !clearErrors.isEmpty {
            throw clearErrors.removeFirst()
        }
    }
}

private extension Currency {
    static func stub(id: String) -> Currency {
        Currency(id: id, title: "Coin \(id)", name: "C\(id)", imageURL: nil)
    }
}
