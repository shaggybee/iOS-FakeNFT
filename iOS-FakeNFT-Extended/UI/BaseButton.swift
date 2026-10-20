//
//  BaseButton.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 20.10.2026.
//

import SwiftUI

struct BaseButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.bold17)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(.blackPrimary)
                .foregroundStyle(.whitePrimary)
                .cornerRadius(16)
        }
    }
}

#Preview {
    BaseButton(
        title: "Оплатить",
        action: {}
    )
    .padding()
}
