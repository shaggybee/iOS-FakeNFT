import SwiftUI

struct ProfileNFTCell: View {
    let item: Nft
    let isLiked: Bool

    var body: some View {
        HStack(spacing: 20) {
            ProfileNFTArtwork(url: item.images.first)
            .frame(width: 108, height: 108)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityHidden(true)
            .overlay(alignment: .topTrailing) {
                Image(systemName: AppSystemIcon.heartFilled)
                    .font(.system(size: 18))
                    .foregroundStyle(isLiked ? .redUniversal : .whiteUniversal)
                    .padding(8)
                    .accessibilityLabel(Text(LocalizedStringKey(isLiked ? "ProfileNFT.liked" : "ProfileNFT.notLiked")))
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(AppFont.bold17)
                        .lineLimit(2)
                        .accessibilityIdentifier("profile.nfts.name")
                    RatingView(rating: item.rating)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(String(
                            format: NSLocalizedString("ProfileNFT.rating", comment: "Accessible rating out of five"),
                            max(0, min(5, item.rating))
                        ))
                    Text(String(format: NSLocalizedString("ProfileNFT.author", comment: "NFT author"), item.author))
                        .font(AppFont.regular13)
                        .lineLimit(2)
                        .accessibilityIdentifier("profile.nfts.author")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 2) {
                    Text("ProfileNFT.price").font(AppFont.regular13)
                    Text(item.price.formatted(.number.locale(Locale(identifier: "ru_RU")).precision(.fractionLength(2))) + " ETH")
                        .font(AppFont.bold17)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
        }
        .foregroundStyle(.blackPrimary)
        .frame(minHeight: 108)
    }

}
