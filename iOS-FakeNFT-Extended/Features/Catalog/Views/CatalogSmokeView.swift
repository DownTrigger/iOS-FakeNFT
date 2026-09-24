import SwiftUI

struct CatalogSmokeView: View {
    @State private var isDetailPresented = false
    @State private var isSortSheetPresented = false
    
    var body: some View {
        ZStack {
            Button {
                isDetailPresented = true
            } label: {
                Text("Catalog.openNft")
                    .font(.bold17)
                    .foregroundStyle(Color(.fnText))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.fnBackground))
            .sheet(isPresented: $isDetailPresented) {
                NftDetailSmokeView()
            }
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
