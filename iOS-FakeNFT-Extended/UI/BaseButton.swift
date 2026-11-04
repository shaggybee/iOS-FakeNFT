//
//  BaseButton.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 20.10.2026.
//

import SwiftUI

struct BaseButton: View {
    @Environment(\.isEnabled) private var isEnabled
    
    let title: String
    let height: CGFloat
    let action: () -> Void
    
    init(
        title: String,
        height: CGFloat = 60,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.height = height
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.bold17)
                .foregroundStyle(.whitePrimary)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(isEnabled ? .blackPrimary : .blackPrimary.opacity(0.5))
                .clipShape(.rect(cornerRadius: 16))
        }
    }
}

#Preview {
    BaseButton(
        title: "Оплатить",
        action: {}
    )
    .padding()
    
    BaseButton(
        title: "Оплатить",
        height: 40,
        action: {}
    )
    .padding()
}
