import SwiftUI

struct NavigationSortButton: View {
    private static let size: CGFloat = 42

    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(.icSort)
                .foregroundStyle(.fnText)
                .frame(width: Self.size, height: Self.size)
        }
        .designToolbarTrailingInset()
    }
}
