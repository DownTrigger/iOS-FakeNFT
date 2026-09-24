import SwiftUI

struct CartView: View {
    @State private var isSortSheetPresented = false
    
    var body: some View {
        ZStack {
            Text(TabLocalizedText.cart.key)
                .font(.bold17)
                .foregroundStyle(Color(.fnText))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.fnBackground))
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationSortButton {
                    withAnimation {
                        isSortSheetPresented = true
                    }
                }
            }
        }
    }
}
