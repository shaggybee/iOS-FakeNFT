import SwiftUI

struct ProfileAvatarView: View {
    let url: URL?
    let size: CGFloat

    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Image(systemName: AppSystemIcon.profile)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.greyUniversal)
                .padding(8)
        }
        .frame(width: size, height: size)
        .background(.lightGrey)
        .clipShape(Circle())
        .accessibilityLabel("Фото профиля")
    }
}
