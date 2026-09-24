//
//  ProfileView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct ProfileView: View {
    
    @State private var viewModel = UserInformationViewViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            UserInformationView(user: viewModel.user)
            CollectionMenu(viewModel: viewModel)
            
            Spacer()
        }
        .padding(.top, 20)
    }
}

#Preview {
    ProfileView()
}
