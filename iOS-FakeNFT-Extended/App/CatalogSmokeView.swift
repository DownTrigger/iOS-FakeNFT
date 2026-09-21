import SwiftUI

struct CatalogSmokeView: View {
    @State private var isDetailPresented = false

    var body: some View {
        Button {
            isDetailPresented = true
        } label: {
            Text("Catalog.openNft")
                .font(.bold17)
                .foregroundStyle(Color(.fnText))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $isDetailPresented) {
            NftDetailSmokeView()
        }
    }
}
