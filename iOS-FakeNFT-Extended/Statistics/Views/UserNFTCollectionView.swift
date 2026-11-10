//
//  UserNFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 03.11.2026.
//

import SwiftUI

struct UserNFTCollectionView: View {
    
    @State private var viewModel: UserNFTCollectionViewModel
    @State private var isErrorPresented = false
    
    init(userId: String, usersService: UsersService, nftService: NftService, likesService: LikesServiceProtocol, cartService: ShoppingCartServiceProtocol) {
        _viewModel = State(
            initialValue: UserNFTCollectionViewModel(
                userId: userId, usersService: usersService, nftService: nftService, likesService: likesService, cartService: cartService
            )
        )
    }
        
    let columns = [
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
                ZStack {
                    Text("Statistics.nftCollection")
                        .font(AppFont.bold17)
                    HStack {
                        BackButton()
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tint(.blackPrimary)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(viewModel.nfts, id: \.id) { nft in
                            NFTCollectionCardView(
                                nft: nft,
                                isFavorite: viewModel.favoriteIDs.contains(nft.id),
                                isInCart: viewModel.cartIDs.contains(nft.id) ,
                                onFavoriteTap: {
                                    Task {
                                        await viewModel.toggleFavorite(id: nft.id)
                                    }
                                },
                                onCartTap: {
                                    Task {
                                        await viewModel.toggleCart(id: nft.id)
                                    }
                                })
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.top,20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadNFTs()
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            isErrorPresented = newValue != nil
        }
        .alert("Error.loadingData", isPresented: $isErrorPresented) {
            Button("Common.cancel", role: .cancel) {}
            
            Button("Error.retry") {
                Task {
                    await viewModel.loadNFTs()
                }
            }
        }
        .padding(.horizontal, 16)
        .background(.whitePrimary)
    }
}
