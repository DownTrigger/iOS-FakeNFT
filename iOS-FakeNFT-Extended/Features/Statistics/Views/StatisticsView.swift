import SwiftUI

struct StatisticsView: View {
    @State private var viewModel: StatisticsViewModel
    @State private var isSortSheetPresented = false

    @Environment(ServicesAssembly.self)

    private var servicesAssembly

    init(viewModel: StatisticsViewModel? = nil) {
        _viewModel = State(
            initialValue:
                viewModel ?? StatisticsViewModel(
                    userService: UserServiceImpl(
                        networkClient: DefaultNetworkClient()
                    )
                )
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.statistics) { statistic in
                    NavigationLink {
                        UserStatisticDetailView(
                            user: statistic.user
                        )
                    } label: {
                        UserStatisticView(
                            position: statistic.position,
                            name: statistic.user.username,
                            avatar: statistic.user.avatar,
                            countNft: statistic.countNft
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 8)
        }
        .background(.background)
        .sortSheet(
            isPresented: $isSortSheetPresented,
            options: [
                StatisticsSortOption.byName,
                StatisticsSortOption.byRating
            ],
            onSelect: { option in
                switch option {
                case .byName:
                    viewModel.sortStatisticsByName()
                case .byRating:
                    viewModel.sortStatisticsByRating()
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationSortButton {
                    withAnimation {
                        isSortSheetPresented = true
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .tint(.fnText)
                    .frame(width: 30, height: 30)
            }
        }
        .task {
            await viewModel.loadStatistics()
        }
        .appAlert(item: $viewModel.alert)
    }
}

#Preview("Statistics") {
    NavigationStack {
        StatisticsView(viewModel: .preview)
    }
}
