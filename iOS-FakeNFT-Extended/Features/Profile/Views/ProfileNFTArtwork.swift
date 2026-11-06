import SwiftUI

struct ProfileNFTArtwork: View {
    let url: URL?

    var body: some View {
        if let url, url.isFileURL, let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image).resizable().scaledToFill()
        } else {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(.lightGrey)
                    .overlay { Image(systemName: AppSystemIcon.photo).foregroundStyle(.greyUniversal) }
            }
        }
    }
}
