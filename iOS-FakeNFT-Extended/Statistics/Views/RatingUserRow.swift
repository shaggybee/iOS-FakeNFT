//
//  RatingUserRow.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 22.10.2026.
//

import SwiftUI

struct RatingUserRow: View {
    let position: Int
    let name: String
    let avatar: String
    let nftCount: Int
    
    var body: some View {
        HStack {
            Text("\(position)")
                .frame(width: 20)
                .font(AppFont.regular15)
            HStack(spacing: 8) {
                AsyncImage(url: URL(string: avatar)) { phase in
                    switch phase {
                    case .empty, .failure:
                        Image("profile30")
                            .foregroundStyle(.greyUniversal)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
        
                    @unknown default:
                        Image("profile30")
                            .foregroundStyle(.greyUniversal)
                    }
                }
                .frame(width: 28, height: 28)
    
                Text(name)
                    .font(AppFont.bold22)
                Spacer()
                Text("\(nftCount)")
                    .font(AppFont.bold22)
            }
            .padding(.horizontal, 16)
            .frame(height: 80)
            .background(.lightGrey)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
}

#Preview {
    RatingUserRow(position: 1, name: "Alex", avatar: "", nftCount: 112)
}
