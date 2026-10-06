//
//  NftGridCellModel+Preview.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 26.09.2026.
//

import Foundation

extension NftGridCellModel {
    static let preview: [NftGridCellModel] = [
        NftGridCellModel(
            id: "001",
            imageURL: URL(string: "https://img.magnific.com/premium-photo/there-is-white-cat-sitting" +
                          "-cloud-with-stars-sky-generative-ai_958098-95668.jpg?semt=ais_hybrid"),
            name: "Archie",
            rating: 4,
            priceText: "1,78 ETH",
            isLiked: false,
            isInCart: false
        ),
        NftGridCellModel(
            id: "002",
            imageURL: URL(string: "https://i.pinimg.com/originals/f8/00/21/f8002186dbda15d186352208d72aca64.jpg?nii=t"),
            name: "Emma",
            rating: 5,
            priceText: "1,78 ETH",
            isLiked: true,
            isInCart: false
        ),
        NftGridCellModel(
            id: "003",
            imageURL: URL(string: "https://i.pinimg.com/474x/2c/ed/d7/2cedd7b706e551623b519d25301fd25f.jpg?nii=t"),
            name: "Stella",
            rating: 4,
            priceText: "1,78 ETH",
            isLiked: false,
            isInCart: false
        ),
        NftGridCellModel(
            id: "004",
            imageURL: URL(string: "https://i.pinimg.com/736x/b0/79/ae/b079ae8ddf92b9ccfd8b99a6b588d2c5.jpg"),
            name: "Toast",
            rating: 3,
            priceText: "1,78 ETH",
            isLiked: true,
            isInCart: false
        )
    ]
}
