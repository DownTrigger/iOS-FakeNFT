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

    var body: some View {
        statisticsList
            .background(Color(.fnBackground))
            .safeAreaInset(edge: .bottom) {
                if viewModel.isLoadingNextPage {
                    ProgressView()
                        .tint(Color(.fnText))
                        .padding(.vertical, 8)
                }
            }
            .overlay {
                if viewModel.isInitialLoading {
                    AppLoadingView()
                } else if viewModel.hasLoadError && viewModel.alert == nil {
                    ErrorStateView(message: StatisticLocalizedText.loadError.key) {
                        Task { await viewModel.loadNextPage() }
                    }
                }
            }
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
            .task(id: sortOption) { await viewModel.applySort(sortOption) }
            .appAlert(item: $viewModel.alert)
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
                    .task { await viewModel.loadNextPageIfNeeded(currentItem: statistic) }
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
        StatisticsView(service: PreviewUserService())
    }
    .environment(services)
    .environment(UserState(
        profileService: services.userProfileService,
        orderService: services.userOrderService
    ))
    .environment(Router<StatisticsRoute>())
}
