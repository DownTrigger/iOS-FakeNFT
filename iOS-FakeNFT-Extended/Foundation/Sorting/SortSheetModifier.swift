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

    @State private var isCoverPresented = false

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, newValue in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    isCoverPresented = newValue
                }
            }
            .fullScreenCover(isPresented: $isCoverPresented) {
                SortSheetOverlay(
                    screenTitle: screenTitle,
                    options: options,
                    onSelect: onSelect,
                    onDismiss: { isPresented = false }
                )
                .presentationBackground(.clear)
            }
    }
}

private struct SortSheetOverlay<Option: SortOptionProtocol>: View {
    let screenTitle: ScreenLocalizedText
    let options: [Option]
    let onSelect: (Option) -> Void
    let onDismiss: () -> Void

    @State private var isVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if isVisible {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { hide() }

                SortBottomSheet(
                    screenTitle: screenTitle,
                    options: options,
                    onSelect: { option in
                        onSelect(option)
                        hide()
                    },
                    onClose: { hide() }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.25)) {
                isVisible = true
            }
        }
    }

    private func hide() {
        withAnimation(.easeIn(duration: 0.2)) {
            isVisible = false
        } completion: {
            onDismiss()
        }
    }
}

#Preview {
    @Previewable @State var isPresented = false

    Button {
        isPresented = true
    } label: {
        Text(verbatim: "Sort")
    }
    .sortSheet(isPresented: $isPresented, options: [CatalogSortOption.byTitle, .byNftCount]) { _ in }
}
