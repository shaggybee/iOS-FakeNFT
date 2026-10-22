//
//  CatalogView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 21.10.2026.
//

import SwiftUI

struct CatalogView: View {
    @State private var viewModel = CatalogViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.collections) { collection in
                CatalogCellView(
                    coverURL: collection.cover,
                    title: viewModel.title(for: collection)
                )
                .listRowInsets(Constants.rowInsets)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    sortButton
                }
            }
        }
    }

    private var sortButton: some View {
        Button {
            viewModel.sortButtonTapped()
        } label: {
            Image(.sort40)
        }
        .tint(.blackPrimary)
    }
}

private extension CatalogView {
    enum Constants {
        static let rowInsets = EdgeInsets(top: 0, leading: 16, bottom: 21, trailing: 16)
    }
}

#Preview {
    CatalogView()
}
