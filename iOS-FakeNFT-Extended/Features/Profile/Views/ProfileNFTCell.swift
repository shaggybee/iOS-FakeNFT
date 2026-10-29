import SwiftUI

struct ProfileNFTCell: View {
    let item: ProfileNFT
    let isLiked: Bool

    var body: some View {
        HStack(spacing: 20) {
            AsyncImage(url: item.nft.images.first) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(.lightGrey)
                    .overlay { Image(systemName: "photo").foregroundStyle(.greyUniversal) }
            }
            .frame(width: 108, height: 108)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityHidden(true)
            .overlay(alignment: .topTrailing) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(isLiked ? .redUniversal : .whiteUniversal)
                    .padding(8)
                    .accessibilityLabel(isLiked ? "В избранном" : "Не в избранном")
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.nft.name)
                        .font(AppFont.bold17)
                        .lineLimit(2)
                        .accessibilityIdentifier("profile.nfts.name")
                    RatingView(rating: item.nft.rating)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Рейтинг \(max(0, min(5, item.nft.rating))) из 5")
                    Text("от \(item.author.name)")
                        .font(AppFont.regular13)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Цена").font(AppFont.regular13)
                    Text(item.nft.price.formatted(.number.locale(Locale(identifier: "ru_RU")).precision(.fractionLength(2))) + " ETH")
                        .font(AppFont.bold17)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
        .foregroundStyle(.blackPrimary)
        .frame(minHeight: 108)
    }
}
