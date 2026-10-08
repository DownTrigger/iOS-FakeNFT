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
                } else if viewModel.isEmpty {
                    EmptyStateView(message: StatisticLocalizedText.emptyUsers.key)
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
        List(viewModel.statistics) { statistic in
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
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .task { await viewModel.loadNextPageIfNeeded(currentItem: statistic) }
        }
        .listStyle(.plain)
        .contentMargins(.top, 20, for: .scrollContent)
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
