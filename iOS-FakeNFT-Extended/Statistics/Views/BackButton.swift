//
//  BackButton.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 03.11.2026.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
            Button {
                dismiss()
            } label: {
                Image(.backward24)
                    .foregroundStyle(.blackPrimary)
                    .frame(width: 24, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
