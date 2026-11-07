//
//  UserNFTCollectionViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 04.11.2026.
//

import Observation
import SwiftUI

@Observable
@MainActor

final class UserNFTCollectionViewModel {
    
    var isLoading = false
    var errorMessage: String?
    
    var nfts: [Nft] = []
    var favoriteIDs: Set<String> = []
    var cartIDs: Set<String> = []
    
    private let userId: String
    private let usersService: UsersService
    private let nftService: NftService
    
    private let likesService: LikesServiceProtocol
    private let cartService: ShoppingCartServiceProtocol
    
    init(userId: String, usersService: UsersService, nftService: NftService, likesService: LikesServiceProtocol, cartService: ShoppingCartServiceProtocol) {
        self.userId = userId
        self.usersService = usersService
        self.nftService = nftService
        self.likesService = likesService
        self.cartService = cartService
    }
    
    func toggleFavorite(id: String) async {
        let previousFavorites = favoriteIDs
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        do {
            try await likesService.updateLikes(favoriteIDs)
        } catch {
            favoriteIDs = previousFavorites
            errorMessage = "Не удалось обновить избранное"
        }
    }
    
    func toggleCart(id: String) async {
        let previousCart = cartIDs
        
        if cartIDs.contains(id) {
            cartIDs.remove(id)
        } else {
            cartIDs.insert(id)
        }
        
        do {
            try await cartService.updateCart(with: cartIDs)
        } catch {
            cartIDs = previousCart
            errorMessage = "Не удалось обновить корзину"
        }
    }
    
    func loadFavoritesAndCart() async {
        do {
            favoriteIDs = try await likesService.loadLikes()
            cartIDs = try await cartService.loadOrder()
        } catch {
            errorMessage = "Не удалось загрузить избранное или корзину"
        }
    }
    
    func loadNFTs() async {
        isLoading = true
        errorMessage = nil
        nfts = []
        
        defer {
            isLoading = false
        }
        
        do {
            let user = try await usersService.loadUser(id: userId)
            var loadedNFTs: [Nft] = []
            
            for nftId in user.nfts {
                let nft = try await nftService.loadNft(id: nftId)
                loadedNFTs.append(nft)
            }
            nfts = loadedNFTs
            await loadFavoritesAndCart()
            
        } catch {
            errorMessage = "Errror"
        }
    }
}

#Preview {
    let nftService = MockNftService()
    
    NavigationStack {
        UserNFTCollectionView(userId: "1", usersService: MockUsersService(), nftService: MockNftService(), likesService: LikesServiceMock(), cartService: ShoppingCartServiceMock(orderService: OrderServiceMock(), nftService: nftService))
    }
}


