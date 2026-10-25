//
//  CollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 25.10.2026.
//

import SwiftUI
import Kingfisher

private enum Constants {
    static let coverHeight: CGFloat = 310
    static let coverCornerRadius: CGFloat = 12
    static let horizontalPadding: CGFloat = 16
    static let headerTopPadding: CGFloat = 16
    static let authorTopPadding: CGFloat = 13
    static let authorSpacing: CGFloat = 4
    static let descriptionTopPadding: CGFloat = 5
    static let gridTopPadding: CGFloat = 24
    static let gridRowSpacing: CGFloat = 28
    static let gridColumnSpacing: CGFloat = 9
    static let bottomPadding: CGFloat = 24
    static let columns = Array(
        repeating: GridItem(.flexible(), spacing: gridColumnSpacing, alignment: .top),
        count: 3
    )
}

struct CollectionView: View {
    @Environment(\.dismiss) private var dismiss

    let collection: NftCollection
    let nfts: [CollectionNftCellModel]
    var onAuthorTap: () -> Void = {}
    var onLikeTap: (CollectionNftCellModel) -> Void = { _ in }
    var onCartTap: (CollectionNftCellModel) -> Void = { _ in }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                cover
                header
                    .padding(.top, Constants.headerTopPadding)
                grid
                    .padding(.top, Constants.gridTopPadding)
            }
            .padding(.bottom, Constants.bottomPadding)
        }
        .ignoresSafeArea(edges: .top)
        .scrollIndicators(.hidden)
        .navigationBarBackButtonHidden()
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                backButton
            }
        }
    }

    // MARK: - Private Views

    private var cover: some View {
        Color(.lightGrey)
            .frame(height: Constants.coverHeight)
            .overlay {
                KFImage(collection.cover)
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(
                .rect(
                    bottomLeadingRadius: Constants.coverCornerRadius,
                    bottomTrailingRadius: Constants.coverCornerRadius
                )
            )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(collection.name)
                .font(AppFont.bold22)
                .foregroundStyle(.blackPrimary)

            HStack(alignment: .firstTextBaseline, spacing: Constants.authorSpacing) {
                Text(String(localized: "Collection.author"))
                    .font(AppFont.regular13)
                    .foregroundStyle(.blackPrimary)
                Button(collection.author, action: onAuthorTap)
                    .font(AppFont.regular15)
                    .foregroundStyle(.blueUniversal)
                    .lineLimit(1)
            }
            .padding(.top, Constants.authorTopPadding)

            Text(collection.description)
                .font(AppFont.regular13)
                .foregroundStyle(.blackPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, Constants.descriptionTopPadding)
        }
        .padding(.horizontal, Constants.horizontalPadding)
    }

    private var grid: some View {
        LazyVGrid(columns: Constants.columns, spacing: Constants.gridRowSpacing) {
            ForEach(nfts) { nft in
                CollectionCellView(
                    model: nft,
                    onLikeTap: { onLikeTap(nft) },
                    onCartTap: { onCartTap(nft) }
                )
            }
        }
        .padding(.horizontal, Constants.horizontalPadding)
    }

    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(.backward24)
                .renderingMode(.template)
        }
        .tint(.blackPrimary)
    }
}

#Preview {
    NavigationStack {
        CollectionView(
            collection: .peachMock,
            nfts: CollectionNftCellModel.mocks
        )
    }
}
