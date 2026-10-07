import SwiftUI

struct UserStatisticDetailView: View {
    let statistic: UserStatisticItem

    @Environment(Router<StatisticsRoute>.self) private var router

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ReusableUserInformationView(user: statistic.user)
                    .padding(.top, 20)

                if let website = statistic.user.userWebSite,
                   !website.isEmpty,
                   let url = URL(string: website) {
                    WebsiteNavigationButton(url: url)
                        .padding(.horizontal, 16)
                        .padding(.top, 28)
                }

                NFTCollectionNavigationLink(nfts: statistic.nfts)
                    .padding(.top, 42)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.fnBackground))
        .toolbar(.hidden, for: .tabBar)
        .backButton { router.pop() }
    }
}

#Preview("Alex — Website") {
    NavigationStack {
        if let user = PreviewUserService.users.first(where: { $0.name == "Alex" }) {
            let statistic = UserStatisticItem(position: 1, response: user)
            UserStatisticDetailView(statistic: statistic)
        }
    }
    .environment(Router<StatisticsRoute>())
}
