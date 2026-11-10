//
//  UserProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 30.10.2026.
//

import SwiftUI

private enum Constants {
    static let avatarSpacing: CGFloat = 16
}

struct UserProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: UserProfileViewModel
    
    private let nftService: NftService
    private let usersService: UsersService
    private let likesService: LikesServiceProtocol
    private let cartService: ShoppingCartServiceProtocol
    
    init(userId: String, usersService: UsersService, nftService: NftService, likesService: LikesServiceProtocol, cartService: ShoppingCartServiceProtocol) {
        
        self.usersService = usersService
        self.nftService = nftService
        self.likesService = likesService
        self.cartService = cartService
        
        _viewModel = State(
            initialValue: UserProfileViewModel(
                userId: userId,
                usersService: usersService
            )
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let user = viewModel.user {
                HStack(spacing: Constants.avatarSpacing) {
                    AsyncImage(url: URL(string: user.avatar)) { image in image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(.profile30)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.greyUniversal)
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    
                    Text(user.name)
                        .font(AppFont.bold22)
                        .foregroundStyle(.blackPrimary)
                }
                
                Text(user.description ?? "")
                    .font(AppFont.regular13)
                    .padding(.top, 20)
                    .foregroundStyle(.blackPrimary)
                
                if let url = URL(string: user.website) {
                    NavigationLink {
                        WebView(url: url)
                    } label: {
                        Text("Statistics.openWebsite")
                            .font(AppFont.regular15)
                            .foregroundStyle(.blackPrimary)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.blackPrimary, lineWidth: 1))
                    .padding(.top, 28)
                }
                NavigationLink {
                UserNFTCollectionView(userId: user.id, usersService: usersService , nftService: nftService, likesService: likesService, cartService: cartService)
                } label: {
                    HStack {
                        Text(String(format: NSLocalizedString("Statistics.nftCollection.count", comment: "User NFT collection with count"),
                                    user.nfts.count))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(AppFont.bold17)
                    .foregroundStyle(.blackPrimary)
                }
                .padding(.top, 41)
            }
            
            Spacer()
        }
        
        .task {
            await viewModel.loadUser()
        }
        .padding(.horizontal, 16)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(.backward24)
                        .tint(.blackPrimary)
                }
            }
        }
    }
}

#Preview {
    let nftService = MockNftService()
    
    NavigationStack {
        UserProfileView(userId: "1", usersService: MockUsersService(), nftService: nftService, likesService: LikesServiceMock(), cartService: ShoppingCartServiceMock(orderService: OrderServiceMock(), nftService: nftService))
    }
}
