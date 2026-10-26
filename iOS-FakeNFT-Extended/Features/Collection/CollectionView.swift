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
    @Environment(\.openURL) private var openURL
    @State private var viewModel: CollectionViewModel

    init(viewModel: CollectionViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationBarBackButtonHidden()
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
            .onAppear {
                viewModel.onAppear()
            }
            .alert(
                String(localized: "Error.title"),
                isPresented: $viewModel.isLikeErrorPresented
            ) {
                Button(String(localized: "Common.close"), role: .cancel) {}
            } message: {
                Text(String(localized: "Collection.likeError"))
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView()
        case .error:
            ErrorStateView(
                message: String(localized: "Collection.loadingError"),
                onRetry: viewModel.retryButtonTapped
            )
            .padding(.horizontal, Constants.horizontalPadding)
        case .empty:
            EmptyView()
        case .loaded(let model):
            loaded(model)
        }
    }

    // MARK: - Private Views

    private func loaded(_ model: CollectionScreenModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                cover(model.collection)
                header(model.collection)
                    .padding(.top, Constants.headerTopPadding)
                grid(model.nfts)
                    .padding(.top, Constants.gridTopPadding)
            }
            .padding(.bottom, Constants.bottomPadding)
        }
        .ignoresSafeArea(edges: .top)
        .scrollIndicators(.hidden)
    }

    private func cover(_ collection: NftCollection) -> some View {
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

    private func header(_ collection: NftCollection) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(collection.name)
                .font(AppFont.bold22)
                .foregroundStyle(.blackPrimary)

            HStack(alignment: .firstTextBaseline, spacing: Constants.authorSpacing) {
                Text(String(localized: "Collection.author"))
                    .font(AppFont.regular13)
                    .foregroundStyle(.blackPrimary)
                Button(collection.author) {
                    if let website = collection.website {
                        openURL(website)
                    }
                }
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

    private func grid(_ nfts: [CollectionNftCellModel]) -> some View {
        LazyVGrid(columns: Constants.columns, spacing: Constants.gridRowSpacing) {
            ForEach(nfts) { nft in
                CollectionCellView(
                    model: nft,
                    onLikeTap: { viewModel.likeButtonTapped(nft) },
                    onCartTap: {}
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
            viewModel: CollectionViewModel(
                collectionId: NftCollection.peachMock.id,
                collectionService: CollectionServiceStub(),
                nftService: NftServiceStub(),
                likesService: LikesServiceStub()
            )
        )
    }
}
