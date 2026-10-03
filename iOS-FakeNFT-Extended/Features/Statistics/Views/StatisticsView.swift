import SwiftUI

struct StatisticsView: View {
    @State private var viewModel: StatisticsViewModel?
    @State private var isSortSheetPresented = false

    @Environment(ServicesAssembly.self) private var servicesAssembly

    let isActive: Bool

    // для preview
    init(
        isActive: Bool = true,
        viewModel: StatisticsViewModel? = nil
    ) {
        self.isActive = isActive
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if let viewModel {
                content(viewModel: viewModel)
            } else {
                ProgressView()
                    .task {
                        viewModel = StatisticsViewModel(
                            userService: servicesAssembly.userService
                        )
                    }
            }
        }
        .onChange(of: isActive) { oldValue, newValue in
            if oldValue && !newValue {
                viewModel?.resetCache()
            }
        }
    }

    @ViewBuilder
    private func content(viewModel: StatisticsViewModel) -> some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.statistics) { statistic in
                    NavigationLink {
                        UserStatisticDetailView(statistic: statistic)
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
            .environment(
                ServicesAssembly(
                    networkClient: DefaultNetworkClient(),
                    nftStorage: NftStorageImpl()
                )
            )
    }
}
