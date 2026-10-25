//
//  CollectionCellView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 25.10.2026.
//

import SwiftUI
import Kingfisher

// MARK: - Constants

private enum Constants {
    static let imageCornerRadius: CGFloat = 12
    static let buttonSize: CGFloat = 40
    static let spacing: CGFloat = 8
    static let infoSpacing: CGFloat = 4
}

// MARK: - CollectionCellView

struct CollectionCellView: View {

    // MARK: - Properties

    let model: CollectionNftCellModel
    let onLikeTap: () -> Void
    let onCartTap: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.spacing) {
            image
            VStack(alignment: .leading, spacing: Constants.infoSpacing) {
                RatingView(rating: model.rating)
                info
            }
        }
    }

    // MARK: - Private Views

    private var image: some View {
        Color(.lightGrey)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                KFImage(model.imageURL)
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(.rect(cornerRadius: Constants.imageCornerRadius))
            .overlay(alignment: .topTrailing) {
                likeButton
            }
    }

    private var likeButton: some View {
        Button(action: onLikeTap) {
            Image(.favorites42)
                .renderingMode(.template)
                .foregroundStyle(model.isLiked ? Color(.redUniversal) : Color(.whiteUniversal))
                .frame(width: Constants.buttonSize, height: Constants.buttonSize)
        }
        .buttonStyle(.plain)
    }

    private var info: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Constants.infoSpacing) {
                Text(model.name)
                    .font(AppFont.bold17)
                    .foregroundStyle(.blackPrimary)
                    .lineLimit(1)
                Text("\(model.price.formatted()) ETH")
                    .font(AppFont.medium10)
                    .foregroundStyle(.blackPrimary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            cartButton
        }
    }

    private var cartButton: some View {
        Button(action: onCartTap) {
            Image(model.isInCart ? .cartDelete40 : .cartAdd40)
                .renderingMode(.template)
                .foregroundStyle(.blackPrimary)
                .frame(width: Constants.buttonSize, height: Constants.buttonSize)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    HStack(alignment: .top, spacing: 9) {
        ForEach(CollectionNftCellModel.mocks.prefix(3)) { model in
            CollectionCellView(model: model, onLikeTap: {}, onCartTap: {})
        }
    }
    .padding()
}
