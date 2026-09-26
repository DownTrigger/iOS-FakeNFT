//
//  SortBottomSheet.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 23.09.2026.
//

import SwiftUI

struct SortBottomSheet<Option: SortOptionProtocol>: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let screenTitle: ScreenLocalizedText
    let options: [Option]
    
    let onSelect: (Option) -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                Text(screenTitle.key)
                    .font(.regular13)
                    .tracking(-0.08)
                    .foregroundStyle(.secondary)
                    .frame(height: 38)
                
                Divider()
                
                ForEach(options) { option in
                    Button {
                        onSelect(option)
                    } label: {
                        Text(option.title.key)
                            .font(.system(size: 20))
                            .tracking(0.38)
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    }
                    
                    if option.id != options.last?.id {
                        Divider()
                    }
                }
            }
            .background(
                colorScheme == .light
                ? AnyShapeStyle(.thinMaterial)
                : AnyShapeStyle(.fnSheetBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 13))
            
            Button {
                onClose()
            } label: {
                Text(SortingLocalizedText.close.key)
                    .font(.system(size: 20, weight: .bold))
                    .tracking(0.38)
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .background(
                colorScheme == .light
                ? AnyShapeStyle(.background)
                : AnyShapeStyle(.fnSheetBackground))
            .clipShape(RoundedRectangle(cornerRadius: 13))
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

#Preview("Catalog") {
    ZStack {
        Color.black.opacity(0.35)
            .ignoresSafeArea()
        
        SortBottomSheet(
            screenTitle: .sorting,
            options: [
                CatalogSortOption.byTitle,
                CatalogSortOption.byNftCount
            ],
            onSelect: { _ in },
            onClose: { }
        )
    }
}

#Preview("Cart") {
    ZStack {
        Color.black.opacity(0.35)
            .ignoresSafeArea()
        
        SortBottomSheet(
            screenTitle: .sorting,
            options: [
                CartSortOption.byPrice,
                CartSortOption.byRating,
                CartSortOption.byTitle
            ],
            onSelect: { _ in },
            onClose: { }
        )
    }
}

#Preview("Profile") {
    ZStack {
        Color.black.opacity(0.35)
            .ignoresSafeArea()
        
        SortBottomSheet(
            screenTitle: .profilePhoto,
            options: [
                CartSortOption.byPrice,
                CartSortOption.byRating,
                CartSortOption.byTitle
            ],
            onSelect: { _ in },
            onClose: { }
        )
    }
}

#Preview("Statistics") {
    ZStack {
        Color.black.opacity(0.35)
            .ignoresSafeArea()
        
        SortBottomSheet(
            screenTitle: .sorting,
            options: [
                StatisticsSortOption.byName,
                StatisticsSortOption.byRating
            ],
            onSelect: { _ in },
            onClose: { }
        )
    }
}
