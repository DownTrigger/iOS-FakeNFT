//
//  NavigationSortButton.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 24.09.2026.
//

import SwiftUI

struct NavigationSortButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(.icSort)
                .font(.system(size: 21))
                .foregroundStyle(.fnText)
        }
    }
}
