//
//  NftLogoView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 26.10.2026.
//

import SwiftUI

struct NftLogoView: View {
    let url: URL?
    
    var body: some View {
        if let url {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if phase.error != nil {
                    nftPlaceholder
                } else {
                    LoadingView()
                        .background(.whiteUniversal)
                }
            }
        } else {
            nftPlaceholder
        }
    }
    
    private var nftPlaceholder: some View {
        Image(.nftPlaceholder)
            .resizable()
            .scaledToFill()
    }
}

#Preview {
    NftLogoView(url: nil)
}
