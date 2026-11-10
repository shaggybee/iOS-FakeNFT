//
//  StatisticsRatingView.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 22.10.2026.
//

import SwiftUI

struct StatisticsRatingView: View {
    
    @Environment(ServicesAssembly.self)
    private var serviceAssembly
    
    var body: some View {
        RatingScreen(usersService: serviceAssembly.usersService, nftService: serviceAssembly.nftService, likesService: serviceAssembly.likesService, cartService: serviceAssembly.shoppingCartService)
    }
}

private struct RatingScreen: View {
    
    @State private var viewModel: RatingViewModel
    @State private var isSortPresented = false
    @State private var isErrorPresented = false
    @State private var selectedUserId: String?
    
    private let usersService: UsersService
    private let nftService: NftService
    private let likesService: LikesServiceProtocol
    private let cartService: ShoppingCartServiceProtocol
    
    init(usersService: UsersService, nftService: NftService, likesService: LikesServiceProtocol, cartService: ShoppingCartServiceProtocol) {
        self.usersService = usersService
        self.nftService = nftService
        self.likesService = likesService
        self.cartService = cartService
        
        _viewModel = State(initialValue: RatingViewModel(usersService: usersService))
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tint(.blackPrimary)
            } else if viewModel.errorMessage != nil {
                Spacer()
            } else {
                HStack {
                    Spacer()
                    Button {
                        isSortPresented = true
                    } label: {
                        Image("sort40")
                            .foregroundStyle(.blackPrimary)
                    }
                }
                .padding(.horizontal, 16)
                
                List {
                    ForEach(Array(viewModel.users.enumerated()), id: \.element.id) { index, user in
                        
                        Button {
                            selectedUserId = user.id
                        } label: {
                            RatingUserRow(position: index + 1, name: user.name, avatar: user.avatar, nftCount: user.nftCount)
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .navigationDestination(item: $selectedUserId) { userId in
            UserProfileView(userId: userId, usersService: usersService, nftService: nftService, likesService: likesService, cartService: cartService)
        }
        .task {
            await viewModel.loadUsers()
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            isErrorPresented = newValue != nil
        }
        .alert("Не удалось получить данные", isPresented: $isErrorPresented) {
            Button("Отмена", role: .cancel) {}
            
            Button("Повторить") {
                Task {
                    await viewModel.loadUsers()
                }
            }
        }
        .confirmationDialog("Сортировка", isPresented: $isSortPresented, titleVisibility: .visible) {
            Button("По имени") {
                viewModel.sortUsers(by: .name)
            }
            Button("По рейтингу") {
                viewModel.sortUsers(by: .rating)
            }
            Button("Закрыть", role: .cancel) {
                
            }
        }
    }
}

#Preview {
    StatisticsRatingView()
        .environment(ServicesAssembly(
            networkClient: DefaultNetworkClient(),
            nftStorage: NftStorageImpl()))
}
