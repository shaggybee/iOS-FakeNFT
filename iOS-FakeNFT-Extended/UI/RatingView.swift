//
//  RatingView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 20.10.2026.
//

import SwiftUI

struct RatingView: View {
    let rating: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<Constants.maxRaiting, id: \.self) { index in
                Image(.star12)
                    .renderingMode(.template)
                    .foregroundStyle(getColor(for: index))
            }
        }
    }
    
    private func getColor(for index: Int) -> Color {
        index < rating ? Color(.yellowUniversal) : Color(.lightGrey)
    }
}

private extension RatingView {
    enum Constants {
        static let maxRaiting: Int = 5
    }
}

#Preview {
    VStack(spacing: 8) {
        RatingView(rating: 0)
        RatingView(rating: 1)
        RatingView(rating: 2)
        RatingView(rating: 3)
        RatingView(rating: 4)
        RatingView(rating: 5)
    }
}
