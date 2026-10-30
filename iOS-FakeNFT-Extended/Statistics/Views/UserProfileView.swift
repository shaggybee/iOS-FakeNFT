//
//  UserProfileView.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 30.10.2026.
//

import SwiftUI

struct UserProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: UserProfileViewModel
    
    init(userId: String, usersService: UsersService) {
        _viewModel = State(
            initialValue: UserProfileViewModel(
                userId: userId,
                usersService: usersService
            )
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .medium))//!
                    .foregroundStyle(.blackPrimary)
                    .frame(width: 24, height: 24, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.bottom, 20)
            
            if let user = viewModel.user {
                HStack(spacing: 16) {
                    AsyncImage(url: URL(string: user.avatar)) { image in image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image("profile30")
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
                
                Text(user.description)
                    .font(AppFont.regular13)
                    .padding(.top, 20)
                    .foregroundStyle(.blackPrimary)
                
                if let url = URL(string: user.website) {
                    NavigationLink {
                        UserWebsiteView(url: url)
                    } label: {
                        Text("Перейти на сайт пользователя")
                            .font(AppFont.regular15)
                            .foregroundStyle(.blackPrimary)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.blackPrimary, lineWidth: 1))
                    .padding(.top, 28)
                }
                Button {
                    // Переход к коллекции (модуль 3)
                } label: {
                    HStack {
                        Text("Коллекция NFT (\(user.nfts.count))")
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
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    UserProfileView(userId: "1", usersService: MockUsersService())
}
