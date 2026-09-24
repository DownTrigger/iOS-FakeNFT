//
//  UserStatisticView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 24.09.2026.
//

import SwiftUI

struct UserStatisticView: View {
    let position: Int
    let name: String
    let avatar: Image
    let countNft: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(position)")
                .font(.regular15)
                .tracking(-0.24)
                .foregroundStyle(.fnText)
                .frame(width: 22)
            
            HStack(spacing: 10) {
                
                avatar
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                
                Text(name)
                    .font(.bold22)
                    .foregroundStyle(.fnText)
                    .tracking(0.35)
                
                Spacer()
                
                Text("\(countNft)")
                    .font(.bold22)
                    .foregroundStyle(.primary)
                    .frame(alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .frame(height: 80)
            .background(Color(.fnLightGray))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        UserStatisticView(
            position: 1,
            name: "Alex",
            avatar: Image("imgAvatarPlaceholder"),
            countNft: 112
        )
        
        UserStatisticView(
            position: 2,
            name: "Maria",
            avatar: Image("imgAvatarPlaceholder"),
            countNft: 98
        )
        
        UserStatisticView(
            position: 3,
            name: "Ivan",
            avatar: Image("imgAvatarPlaceholder"),
            countNft: 76
        )
    }
    .padding()
}
