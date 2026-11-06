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
    
    init(userId: String, usersService: UsersService, nftService: NftService) {
        self.userId = userId
        self.usersService = usersService
        self.nftService = nftService
    }
    
    func toggleFavorite(id: String) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
    }
    
    func toggleCart(id: String) {
        if cartIDs.contains(id) {
            cartIDs.remove(id)
        } else {
            cartIDs.insert(id)
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
                
        } catch {
            errorMessage = "Errror" // TODO: добавить NSLocalizedString
        }
        
        
    }
}

#Preview {
    NavigationStack {
        UserNFTCollectionView(userId: "1", usersService: MockUsersService(), nftService: MockNftService())
    }
}
