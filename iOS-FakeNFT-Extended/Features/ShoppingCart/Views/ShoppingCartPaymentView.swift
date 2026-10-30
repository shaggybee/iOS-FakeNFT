//
//  ShoppingCartPaymentView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 23.10.2026.
//

import SwiftUI

struct ShoppingCartPaymentView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: ShoppingCartPaymentViewModel
    
    init(viewModel: ShoppingCartPaymentViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            switch viewModel.viewState {
            case .idle, .loading:
                LoadingView()
            case .loaded:
                if viewModel.isCurrenciesListEmpty {
                    EmptyStateView(message: NSLocalizedString("Payment.emptyCurrenciesList", comment: ""))
                } else {
                    content
                }
            case .error:
                if !viewModel.isFetchingCurrenciesErrorShown {
                    ErrorStateView(
                        message: NSLocalizedString("Payment.loadCurrenciesError", comment: ""),
                        onRetry: {
                            viewModel.retryLoadCurrencies()
                        })
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.whitePrimary)
        .navigationTitle("Payment.selection")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .allowsHitTesting(viewModel.payingState != .paying)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(.backward24)
                        .tint(.blackPrimary)
                }
                .disabled(viewModel.payingState == .paying)
            }
        }
        .alert(Text("Error.fetchData"), isPresented: $viewModel.isFetchingCurrenciesErrorShown) {
            Button("Button.retry") {
                viewModel.retryLoadCurrencies()
            }
            Button("Button.cancel", role: .cancel) { }
        }
        .alert(viewModel.paymentErrorMessage, isPresented: $viewModel.isPaymentErrorAlertPresented) {
            Button("Button.retry") {
                Task {
                    await viewModel.pay()
                }
            }
            Button("Button.cancel", role: .cancel) { }
        }
        .overlay {
            if viewModel.payingState == .paying {
                BlockingProgressView()
            }
        }
        .task(id: viewModel.currenciesLoadToken) {
            await viewModel.loadCurrencies()
        }
    }
    
    private var content: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible())], spacing: 8) {
                    ForEach(viewModel.currencies, id: \.id) { currency in
                        PaymentCurrencyCellView(
                            model: viewModel.getPreparedCurrencyCellModel(from: currency),
                            isSelected: currency.id == viewModel.selectedCurrency?.id
                        ) { viewModel.selectedCurrency = currency }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, 16)
            .padding(.top, 20)
            
            footerBlock
        }
    }
    
    private var footerBlock: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Payment.agreement")
                    .foregroundStyle(.blackPrimary)
                    .font(AppFont.regular13)
                Button {
                    // TODO добавить переход к пользовательскому соглашению
                } label: {
                    Text("Payment.agreementLink")
                        .foregroundStyle(.blueUniversal)
                        .font(AppFont.regular13)
                }
            }
            
            BaseButton(title: NSLocalizedString("Payment.pay", comment: ""), action: {
                    Task { await viewModel.pay() }
                })
            .disabled(!viewModel.canPay)
        }
        .padding(16)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
                .fill(.lightGrey)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    let viewModel = ShoppingCartPaymentViewModel(
        currenciesService: CurrenciesServiceMock(),
        shoppingCartService: ShoppingCartServiceMock(
            orderService: OrderServiceMock(),
            nftService: NftServiceMock()
        )
    )
    
    ShoppingCartPaymentView(viewModel: viewModel)
}
