import SwiftUI

struct StatisticsView: View {
    var body: some View {
        Text(TabLocalizedText.statistics.key)
            .font(.bold17)
            .foregroundStyle(Color(.fnText))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.fnBackground))
    }
}
