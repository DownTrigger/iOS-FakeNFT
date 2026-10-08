import SwiftUI

struct PaymentView: View {
    private static let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 2)

    @Environment(ServicesAssembly.self) private var services
    @Environment(Router<CartRoute>.self) private var router
    @Environment(UserState.self) private var userState
    @State private var viewModel = PaymentViewModel()

    var body: some View {
        VStack(spacing: 0) {
            content
            bottomPanel
        }
        .background(Color(.fnBackground))
        .overlay {
            if viewModel.isPaying {
                AppLoadingView()
            }
        }
        .navigationTitle(CartLocalizedText.paymentTitle.key)
        .navigationBarTitleDisplayMode(.inline)
        .backButton { router.pop() }
        .toolbar(.hidden, for: .tabBar)
        .task { await viewModel.load(using: services.paymentService) }
        .appAlert(item: $viewModel.alert)
        .onChange(of: viewModel.isPaid) { _, isPaid in
            if isPaid {
                router.push(.success)
                Task { try? await userState.refresh() }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.state.isLoading {
            AppLoadingView()
        } else {
            ScrollView {
                LazyVGrid(columns: Self.columns, spacing: 7) {
                    ForEach(viewModel.currencies) { currency in
                        CurrencyCell(
                            currency: currency,
                            isSelected: currency.id == viewModel.selectedCurrency?.id
                        )
                        .onTapGesture {
                            viewModel.select(currency)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
        }
    }

    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                Text(CartLocalizedText.agreementText.key)
                    .foregroundStyle(Color(.fnText))
                    .frame(minHeight: 22)
                Button {
                    if let url = CartConstants.agreementURL {
                        router.push(.agreement(url))
                    }
                } label: {
                    Text(CartLocalizedText.agreementLink.key)
                        .foregroundStyle(Color(.fnBlue))
                        .frame(minHeight: 22)
                }
            }
            .font(.regular13)

            PrimaryButton(title: .pay, action: pay, isDisabled: !viewModel.canPay)
        }
        .padding(16)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
                .fill(Color(.fnLightGray))
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func pay() {
        Task {
            await viewModel.pay(using: services.paymentService, cartService: services.cartService)
        }
    }
}

#Preview {
    let services = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl()
    )

    NavigationStack {
        PaymentView()
    }
    .environment(services)
    .environment(UserState(profileService: services.userProfileService, orderService: services.userOrderService))
    .environment(Router<CartRoute>())
}
