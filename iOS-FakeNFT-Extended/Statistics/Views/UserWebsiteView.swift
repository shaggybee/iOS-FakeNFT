//
//  UserWebsiteView.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 30.10.2026.
//

import SwiftUI

struct UserWebsiteView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let url: URL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.blackPrimary)
                    .frame(width: 24, height: 24, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
            .padding(.bottom, 9)
            WebView(url: url)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

