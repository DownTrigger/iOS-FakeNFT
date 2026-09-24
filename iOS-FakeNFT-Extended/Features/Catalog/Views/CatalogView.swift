import SwiftUI

struct CatalogView: View {
    @State private var viewModel = CatalogViewModel()
    @State private var isSortSheetPresented = false

    var body: some View {
        List(viewModel.collections) { collection in
            CollectionCell(collection: collection)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 17, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.fnBackground))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.fnBackground))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationSortButton {
                    isSortSheetPresented = true
                }
            }
        }
        .sortSheet(
            isPresented: $isSortSheetPresented,
            options: [CatalogSortOption.byTitle, .byNftCount]
        ) { option in
            viewModel.selectSort(option)
        }
    }
}

#Preview {
    NavigationStack {
        CatalogView()
    }
}
