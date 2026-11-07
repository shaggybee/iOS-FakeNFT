//
//  NFTCollectionCardView.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 03.11.2026.
//

import SwiftUI

struct NFTCollectionCardView: View {
    
    let nft: Nft
    let isFavorite: Bool
    let isInCart: Bool
    
    let onFavoriteTap: () -> Void
    let onCartTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                GeometryReader { geometry in
                    AsyncImage(url: nft.images.first) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .empty, .failure:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.gray.opacity(0.3))
                            
                        @unknown default:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.gray.opacity(0.3))
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .aspectRatio(1, contentMode: .fit)
                        
                Button {
                    onFavoriteTap()
                } label: {
                    Image(.favorites42)
                        .renderingMode(.template)
                        .foregroundStyle(isFavorite ? Color.redUniversal : Color.whiteUniversal)
                        .frame(width: 42, height: 42)
                }
                .padding(8)
            }
            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { index in
                    Image(.star12)
                        .renderingMode(.template)
                        .foregroundStyle(index < nft.rating ? Color.yellowUniversal : Color.lightGrey)
                }
            }
            HStack(alignment: .bottom, spacing: 0) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(nft.name)
                        .font(AppFont.bold17)
                    Text(nft.price.formatted(.number.precision(.fractionLength(2))) + " ETH")
                        .font(AppFont.medium10)
                }
                Spacer(minLength: 0)
                
                Button {
                    onCartTap()
                } label: {
                    Image(isInCart ? .cartDelete40 : .cartAdd40)
                        .foregroundStyle(.blackPrimary)
                }
            }
        }
    }
}

#Preview {
    NFTCollectionCardView(
        nft: Nft(id: "100", name: "Cat", images: [], rating: 2, price: 1.78, author: "Text"),
        isFavorite: false,
        isInCart: false,
        onFavoriteTap: {
            
        },
        onCartTap: {
            
        }
    )
    .frame(width: 110)
    .padding()
}
