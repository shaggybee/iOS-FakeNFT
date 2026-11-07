//
//  CatalogSkeletonView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 03.11.2026.
//

import SwiftUI

struct CatalogSkeletonView: View {
    var body: some View {
        List {
            ForEach(0..<5) { index in
                VStack(alignment: .leading, spacing: 4) {
                    Skeleton()
                        .frame(height: 140)
                        .clipShape(.rect(cornerRadius: 12))

                    Text("Collection")
                        .font(AppFont.bold17)
                        .hidden()
                        .frame(
                            width: index.isMultiple(of: 2) ? 150 : 110,
                            alignment: .leading
                        )
                        .overlay {
                            Skeleton()
                                .clipShape(.rect(cornerRadius: 4))
                        }
                }
                .listRowInsets(
                    EdgeInsets(
                        top: 0,
                        leading: 16,
                        bottom: 21,
                        trailing: 16
                    )
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollDisabled(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Catalog.loading"))
    }
}

// MARK: - Preview

#Preview {
    CatalogSkeletonView()
}
