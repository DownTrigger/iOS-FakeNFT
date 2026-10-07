import SwiftUI

extension View {
    func designToolbarLeadingInset() -> some View {
        modifier(DesignToolbarInset(direction: -1))
    }

    func designToolbarTrailingInset() -> some View {
        modifier(DesignToolbarInset(direction: 1))
    }
}

private struct DesignToolbarInset: ViewModifier {
    private static let designInset: CGFloat = 9
    private static let systemInset: CGFloat = 16

    let direction: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
        } else {
            content.offset(x: direction * (Self.systemInset - Self.designInset))
        }
    }
}
