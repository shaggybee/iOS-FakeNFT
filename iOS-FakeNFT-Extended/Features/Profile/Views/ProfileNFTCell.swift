import SwiftUI

struct ProfileNFTCell: View {
    @Environment(\.locale) private var locale
    let item: Nft
    let isLiked: Bool
    let isUpdating: Bool
    let isEnabled: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            ProfileNFTArtwork(url: item.images.first)
            .frame(width: 108, height: 108)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityHidden(true)
            .overlay(alignment: .topTrailing) {
                Button(action: onToggleFavorite) {
                    Group {
                        if isUpdating { ProgressView().tint(.redUniversal) }
                        else {
                            Image(systemName: AppSystemIcon.heartFilled)
                                .foregroundStyle(isLiked ? .redUniversal : .whiteUniversal)
                        }
                    }
                    .font(.system(size: 18))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!isEnabled)
                .accessibilityLabel(String(format: NSLocalizedString(
                    isLiked ? "ProfileFavorites.remove" : "ProfileFavorites.add", comment: "Toggle favorite NFT"
                ), item.name))
                .accessibilityValue(Text(LocalizedStringKey(isLiked ? "ProfileNFT.liked" : "ProfileNFT.notLiked")))
                .accessibilityIdentifier("profile.nfts.favorite." + item.id)
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
                    Text(String(format: NSLocalizedString("ProfileNFT.price.value", comment: "NFT price in ETH"),
                                item.price.formatted(.number.locale(locale).precision(.fractionLength(2)))))
                        .font(AppFont.bold17)
                        .fixedSize(horizontal: true, vertical: false)
                        .accessibilityIdentifier("profile.nfts.price")
                }
            }
        }
        .foregroundStyle(.blackPrimary)
        .frame(minHeight: 108)
    }

}
