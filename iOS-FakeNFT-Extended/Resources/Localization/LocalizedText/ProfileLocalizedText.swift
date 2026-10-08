import SwiftUI

enum ProfileLocalizedText {
    case myNFTsEmpty
    case myNFTsLoadError
    case profileLoadError
    case favouriteNFTsEmpty
    case favouriteNFTsLoadError
    case editName
    case editDescription
    case editWebsite
    case changePhoto
    case deletePhoto
    case photoLink
    case exitConfirmation
    case stay
    case exit
    case saveError
    case nftAuthor(String)
    case nftPrice

    var key: LocalizedStringKey {
        switch self {
        case .myNFTsEmpty:           "profile.myNFTs.empty"
        case .myNFTsLoadError:       "profile.myNFTs.loadError"
        case .profileLoadError:      "profile.loadError"
        case .favouriteNFTsEmpty:    "profile.favouriteNFTs.empty"
        case .favouriteNFTsLoadError: "profile.favouriteNFTs.loadError"
        case .editName: "profile.edit.name"
        case .editDescription: "profile.edit.description"
        case .editWebsite: "profile.edit.website"
        case .changePhoto: "profile.edit.changePhoto"
        case .deletePhoto: "profile.edit.deletePhoto"
        case .photoLink: "profile.edit.photoLink"
        case .exitConfirmation: "profile.edit.exitConfirmation"
        case .stay: "profile.edit.stay"
        case .exit: "profile.edit.exit"
        case .saveError: "profile.saveError"
        case .nftAuthor(let author): "profile.nft.author \(author)"
        case .nftPrice: "profile.nft.price"
        }
    }

    var resource: LocalizedStringResource {
        switch self {
        case .myNFTsEmpty: "profile.myNFTs.empty"
        case .myNFTsLoadError: "profile.myNFTs.loadError"
        case .profileLoadError: "profile.loadError"
        case .favouriteNFTsEmpty: "profile.favouriteNFTs.empty"
        case .favouriteNFTsLoadError: "profile.favouriteNFTs.loadError"
        case .editName: "profile.edit.name"
        case .editDescription: "profile.edit.description"
        case .editWebsite: "profile.edit.website"
        case .changePhoto: "profile.edit.changePhoto"
        case .deletePhoto: "profile.edit.deletePhoto"
        case .photoLink: "profile.edit.photoLink"
        case .exitConfirmation: "profile.edit.exitConfirmation"
        case .stay: "profile.edit.stay"
        case .exit: "profile.edit.exit"
        case .saveError: "profile.saveError"
        case .nftAuthor(let author): "profile.nft.author \(author)"
        case .nftPrice: "profile.nft.price"
        }
    }
}
