//
//  View+LoadErrorAlert.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 30.10.2026.
//

import SwiftUI

// MARK: - Load Error Alert

extension View {
    func loadErrorAlert(
        isPresented: Binding<Bool>,
        onRetry: @escaping () -> Void
    ) -> some View {
        alert(
            String(localized: "Error.loadingData"),
            isPresented: isPresented
        ) {
            Button(String(localized: "Common.cancel"), role: .cancel) {}
            Button(String(localized: "Error.retry"), action: onRetry)
        }
    }
}
