//
//  ViewState.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 19.10.2026.
//

import Foundation

enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error?)
}
