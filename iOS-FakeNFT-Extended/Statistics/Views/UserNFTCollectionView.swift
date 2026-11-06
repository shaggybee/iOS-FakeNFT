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
    
    init(userId: String, usersService: UsersService, nftService: NftService) {
        _viewModel = State(
            initialValue: UserNFTCollectionViewModel(
                userId: userId, usersService: usersService, nftService: nftService
            )
        )
    }
        
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 0) {
                ZStack {
                    Text("Коллекция NFT")
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
                                    viewModel.toggleFavorite(id: nft.id)
                                },
                                onCartTap: {
                                    viewModel.toggleCart(id: nft.id)
                                })
                        }
                    }
                }
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
        .alert("Не удалось получить данные", isPresented: $isErrorPresented) {
            Button("Отмена", role: .cancel) {}
            
            Button("Повторить") {
                Task {
                    await viewModel.loadNFTs()
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
