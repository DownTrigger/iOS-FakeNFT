//
//  SortSheetModifier.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

extension View {
    func sortSheet<Option: SortOptionProtocol>(
        isPresented: Binding<Bool>,
        screenTitle: ScreenLocalizedText = .sorting,
        options: [Option],
        onSelect: @escaping (Option) -> Void
    ) -> some View {
        modifier(
            SortSheetModifier(
                isPresented: isPresented,
                screenTitle: screenTitle,
                options: options,
                onSelect: onSelect
            )
        )
    }
}
private struct SortSheetModifier<Option: SortOptionProtocol>: ViewModifier {
    @Binding var isPresented: Bool
    
    let screenTitle: ScreenLocalizedText
    let options: [Option]
    let onSelect: (Option) -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    ZStack(alignment: .bottom) {
                        Color(.fnOverlay)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    isPresented = false
                                }
                            }
                        
                        SortBottomSheet(
                            screenTitle: screenTitle,
                            options: options,
                            onSelect: { option in
                                onSelect(option)
                                
                                withAnimation {
                                    isPresented = false
                                }
                            },
                            onClose: {
                                withAnimation {
                                    isPresented = false
                                }
                            }
                        )
                        .transition(.move(edge: .bottom))
                    }
                    .transition(.opacity)
                    
                }
            }
    }
    
}

#Preview {
    @Previewable @State var isPresented = false
    ZStack {
        Color(.systemBackground)
        Button {
            isPresented = true
        } label: {
            Text(verbatim: "Sort")
        }
    }
    .sortSheet(isPresented: $isPresented, options: [CatalogSortOption.byTitle, .byNftCount]) { _ in }
}
