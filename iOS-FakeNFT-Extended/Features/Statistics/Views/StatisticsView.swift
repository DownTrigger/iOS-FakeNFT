import SwiftUI

struct StatisticsView: View {
    @State private var viewModel: StatisticsViewModel
    
    init(viewModel: StatisticsViewModel = StatisticsViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.statistics) { statistic in
                    UserStatisticView(
                        position: statistic.position,
                        name: statistic.user.username,
                        avatar: Image(
                            statistic.user.avatar ?? "imgAvatarPlaceholder"
                        ),
                        countNft: statistic.countNft
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 8)
        }
        .background(.background)
    }
}

#Preview("Statistics") {
    NavigationStack {
        StatisticsView(viewModel: .preview)
    }
}
