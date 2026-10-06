import SwiftUI

extension View {
    func backButton(action: @escaping () -> Void) -> some View {
        navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: action) {
                        Image(.icBack)
                            .renderingMode(.template)
                            .foregroundStyle(Color(.fnText))
                    }
                }
            }
    }
}
