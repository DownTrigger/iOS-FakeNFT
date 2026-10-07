//
//  NavigationSortButton.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 24.09.2026.
//

import SwiftUI

struct NavigationSortButton: View {
    private static let size: CGFloat = 42
    private static let designTrailingInset: CGFloat = 9
    private static let toolbarTrailingInset: CGFloat = 16

    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(.icSort)
                .foregroundStyle(.fnText)
                .frame(width: Self.size, height: Self.size)
        }
        .designTrailingInset(Self.toolbarTrailingInset - Self.designTrailingInset)
    }
}

private extension View {
    @ViewBuilder
    func designTrailingInset(_ offset: CGFloat) -> some View {
        if #available(iOS 26, *) {
            self
        } else {
            self.offset(x: offset)
        }
    }
}
