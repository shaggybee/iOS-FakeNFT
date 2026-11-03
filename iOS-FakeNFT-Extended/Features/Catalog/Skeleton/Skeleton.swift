//
//  Skeleton.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 03.11.2026.
//

import SwiftUI

struct Skeleton: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    @State private var isAnimating = false

    var body: some View {
        Rectangle()
            .fill(.blackPrimary.opacity(0.08))
            .overlay {
                if !reduceMotion {
                    LinearGradient(
                        colors: [
                            .white.opacity(0),
                            .white.opacity(
                                colorScheme == .dark ? 0.12 : 0.55
                            ),
                            .white.opacity(0)
                        ],
                        startPoint: UnitPoint(
                            x: isAnimating ? 2 : -2,
                            y: 0.5
                        ),
                        endPoint: UnitPoint(
                            x: isAnimating ? 3 : -1,
                            y: 0.5
                        )
                    )
                }
            }
            .clipped()
            .onAppear {
                isAnimating = !reduceMotion
            }
            .onChange(of: reduceMotion) { _, value in
                isAnimating = !value
            }
            .animation(
                reduceMotion
                ? nil
                : .easeInOut(duration: 1.8)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .accessibilityHidden(true)
    }
}
