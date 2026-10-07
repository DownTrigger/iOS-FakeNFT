import SwiftUI

extension View {
    func designToolbarTrailingInset() -> some View {
        modifier(DesignToolbarTrailingInset())
    }
}

private struct DesignToolbarTrailingInset: ViewModifier {
    private static let designInset: CGFloat = 9
    private static let systemInset: CGFloat = 16

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
        } else {
            content.offset(x: Self.systemInset - Self.designInset)
        }
    }
}
