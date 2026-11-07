//
//  BlockingProgressView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 19.10.2026.
//

import SwiftUI

struct BlockingProgressView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.loaderBackground)
            .frame(width: 82, height: 82)
            .overlay {
                ProgressView()
                    .tint(.blackUniversal)
                    .scaleEffect(1.5)
            }
    }
}

#Preview {
    BlockingProgressView()
}
