import SwiftUI

struct StatisticsView: View {
    @State private var viewModel: StatisticsViewModel
    @State private var isSortSheetPresented = false
    
    init(viewModel: StatisticsViewModel = StatisticsViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
//        ZStack(alignment: .bottom) {
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
                                avatar: Image(
                                    statistic.user.avatar ?? "imgAvatarPlaceholder"
                                ),
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
//            if isSortSheetPresented {
//                Color(.fnOverlay)
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        isSortSheetPresented = false
//                    }
//                
//                SortBottomSheet(
//                    screenTitle: .sorting,
//                    options: [
//                        StatisticsSortOption.byName,
//                        StatisticsSortOption.byRating
//                    ],
//                    onSelect: { option in
//                        switch option {
//                        case .byName:
//                            viewModel.sortStatisticsByName()
//                            
//                        case .byRating:
//                            viewModel.sortStatisticsByRating()
//                        }
//                        
//                        withAnimation {
//                            isSortSheetPresented = false
//                        }
//                    },
//                    onClose: {
//                        isSortSheetPresented = false
//                    }
//                )
//                .transition(.move(edge: .bottom))
//            }
//        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationSortButton {
                    withAnimation {
                        isSortSheetPresented = true
                    }
                }
            }
        }
    }
}

#Preview("Statistics") {
    NavigationStack {
        StatisticsView(viewModel: .preview)
    }
}
