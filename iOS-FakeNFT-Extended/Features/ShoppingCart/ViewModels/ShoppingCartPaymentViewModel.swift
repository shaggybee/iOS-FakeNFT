//
//  ShoppingCartPaymentViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 28.10.2026.
//

import Foundation

@MainActor
@Observable
final class ShoppingCartPaymentViewModel {
    private(set) var viewState: ViewState<[Currency]> = .idle
    private(set) var payingState: PayingState = .idle
    
    let currenciesService: CurrenciesServiceProtocol
    let shoppingCartService: ShoppingCartServiceProtocol
    var selectedCurrency: Currency?
    var isFetchingCurrenciesErrorShown: Bool = false
    var isPaymentErrorAlertPresented: Bool = false
    
    var currenciesLoadToken: UUID = UUID()
    
    var currencies: [Currency] {
        guard case let .loaded(items) = viewState else {
            return []
        }
        
        return items
    }
    var isCurrenciesListEmpty: Bool { currencies.isEmpty }
    var canPay: Bool { selectedCurrency != nil }
    
    var paymentErrorMessage: String {
        if case .error(let errorState) = payingState {
            return errorState.alertMessage
        }
        return NSLocalizedString("Error.unknown", comment: "")
    }
    
    init(
        currenciesService: CurrenciesServiceProtocol,
        shoppingCartService: ShoppingCartServiceProtocol
    ) {
        self.currenciesService = currenciesService
        self.shoppingCartService = shoppingCartService
    }
    
    func loadCurrencies() async {
        if case .loaded = viewState {
            return
        }
        
        viewState = .loading
        
        do {
            let result = try await currenciesService.loadCurrencies()
            
            viewState = .loaded(result)
        } catch is CancellationError {
            //
        } catch {
            guard !Task.isCancelled else { return }
            
            isFetchingCurrenciesErrorShown = true
            viewState = .error(nil)
        }
    }
    
    func retryLoadCurrencies() {
        currenciesLoadToken = UUID()
    }
    
    func pay() async {
        guard let selectedCurrency else {
            return
        }
        
        do {
            if payingState != .error(.cartClearingFailed) {
                payingState = .paying
                
                try await shoppingCartService.pay(by: selectedCurrency.id)
            }
            payingState = .cartClearing
            
            try await shoppingCartService.clear()
            
            payingState = .paid
        } catch {
            guard !Task.isCancelled else { return }
            
            if payingState == .paying {
                payingState = .error(.paymentFailed)
            } else {
                payingState = .error(.cartClearingFailed)
            }
            
            isPaymentErrorAlertPresented = true
        }
    }
    
    func getPreparedCurrencyCellModel(from currency: Currency) -> PaymentCurrencyCellModel {
        PaymentCurrencyCellModel(
            id: currency.id,
            title: currency.title,
            name: currency.name,
            imageUrl: currency.image
        )
    }
}
