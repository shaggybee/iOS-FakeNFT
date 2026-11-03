//
//  UserWebsiteView.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 30.10.2026.
//

import SwiftUI

struct UserWebsiteView: View {
    
    let url: URL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BackButton()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .padding(.bottom, 9)
            WebView(url: url)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

