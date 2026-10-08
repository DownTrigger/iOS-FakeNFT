import UIKit

enum TabBarAppearance {
    static func configure() {
        let unselectedColor = UIColor(resource: .fnText)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .fnBackground)
        appearance.shadowColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(resource: .fnGray) : .clear
        }
        appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
