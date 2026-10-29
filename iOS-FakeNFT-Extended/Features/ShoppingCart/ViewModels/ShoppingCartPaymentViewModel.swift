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
    
    let currenciesService: CurrenciesServiceProtocol
    var selectedCurrency: Currency?
    var isFetchingCurrenciesErrorShown: Bool = false
    
    var currencies: [Currency] {
        guard case let .loaded(items) = viewState else {
            return []
        }
        
        return items
    }
    var isCurrenciesListEmpty: Bool { currencies.isEmpty }
    
    init(currenciesService: CurrenciesServiceProtocol) {
        self.currenciesService = currenciesService
    }
    
    func loadCurrencies() async {
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
    
    func getPreparedCurrencyCellModel(from currency: Currency) -> PaymentCurrencyCellModel {
        PaymentCurrencyCellModel(
            id: currency.id,
            title: currency.title,
            name: currency.name,
            imageUrl: currency.image
        )
    }
}
