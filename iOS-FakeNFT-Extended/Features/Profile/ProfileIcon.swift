import SwiftUI

enum ProfileIcon: String {
    case editProfile = "square.and.pencil"
    case camera = "camera.fill"

    var image: Image {
        Image(systemName: rawValue)
    }
}
