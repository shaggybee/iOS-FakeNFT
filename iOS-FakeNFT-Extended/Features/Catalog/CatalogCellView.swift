//
//  CatalogCellView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 21.10.2026.
//

import SwiftUI
import Kingfisher

struct CatalogCellView: View {
    let coverURL: URL?
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            cover
            Text(title)
                .font(AppFont.bold17)
                .foregroundStyle(.blackPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var cover: some View {
        Color(.lightGrey)
            .frame(height: Constants.coverHeight)
            .overlay(alignment: .top) {
                KFImage(coverURL)
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
            }
            .clipShape(.rect(cornerRadius: Constants.coverCornerRadius))
            .contentShape(.rect(cornerRadius: Constants.coverCornerRadius))
    }
}

private extension CatalogCellView {
    enum Constants {
        static let coverHeight: CGFloat = 140
        static let coverCornerRadius: CGFloat = 12
    }
}

#Preview {
    CatalogCellView(
        coverURL: NftCollection.mocks[0].cover,
        title: "Peach (11)"
    )
    .padding()
}
