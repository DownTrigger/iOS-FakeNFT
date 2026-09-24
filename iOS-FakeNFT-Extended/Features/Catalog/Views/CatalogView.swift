import SwiftUI

struct CatalogView: View {
    @State private var viewModel = CatalogViewModel()

    var body: some View {
        List(viewModel.collections) { collection in
            Text(collection.name)
                .font(.bold17)
                .foregroundStyle(Color(.fnText))
                .listRowBackground(Color(.fnBackground))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.fnBackground))
    }
}

#Preview {
    CatalogView()
}
