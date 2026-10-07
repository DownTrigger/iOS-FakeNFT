import SwiftUI

struct StatisticsView: View {
    private static let sortOptionKey = "statistics.sortOption"

    @Environment(Router<StatisticsRoute>.self) private var router
    @State private var viewModel: StatisticsViewModel
    @State private var isSortSheetPresented = false
    @AppStorage(Self.sortOptionKey) private var sortOption: StatisticsSortOption = .byRating

    init(service: UserServiceProtocol) {
        _viewModel = State(initialValue: StatisticsViewModel(userService: service))
    }

    init(viewModel: StatisticsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .background(Color(.fnBackground))
            .sortSheet(
                isPresented: $isSortSheetPresented,
                options: [StatisticsSortOption.byName, .byRating]
            ) { option in
                sortOption = option
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationSortButton {
                        isSortSheetPresented = true
                    }
                }
            }
            .task(id: sortOption) { viewModel.applySort(sortOption) }
            .task { await viewModel.load() }
            .appAlert(item: $viewModel.alert)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            AppLoadingView()
        case .loaded:
            statisticsList
        case .failed:
            if viewModel.alert == nil {
                ErrorStateView(message: StatisticLocalizedText.loadError.key) {
                    Task { await viewModel.load() }
                }
            }
        }
    }

    private var statisticsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.statistics) { statistic in
                    Button {
                        router.push(.user(statistic))
                    } label: {
                        UserStatisticView(
                            position: statistic.position,
                            name: statistic.user.username,
                            avatar: statistic.user.avatar,
                            countNft: statistic.nfts.count
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 8)
        }
        .refreshable { await viewModel.refresh() }
    }
}

#Preview("Statistics") {
    let services = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl()
    )
    NavigationStack {
        StatisticsView(viewModel: .preview)
    }
    .environment(services)
    .environment(UserState(
        profileService: services.userProfileService,
        orderService: services.userOrderService
    ))
    .environment(Router<StatisticsRoute>())
}
