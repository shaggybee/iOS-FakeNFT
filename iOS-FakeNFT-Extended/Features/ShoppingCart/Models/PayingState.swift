//
//  PayingState.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 30.10.2026.
//

import Foundation

enum PayingErrorState: Equatable {
    case paymentFailed
    case cartClearingFailed
    
    var alertMessage: String {
        switch self {
        case .paymentFailed: NSLocalizedString("Payment.paymentFailed", comment: "")
        case .cartClearingFailed: NSLocalizedString("Payment.cartClearingFailed", comment: "")
        }
    }
}

enum PayingState: Equatable {
    case idle
    case paying
    case paid
    case cartClearing
    case error(PayingErrorState)
}
