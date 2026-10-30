//
//  MockConstants.swift
//  iOS-FakeNFT-Extended
//
//  Created by Kislov Vadim on 22.10.2026.
//

import Foundation

enum MockConstants {
    static let order = Order(
        id: "1",
        nfts: MockConstants.nfts.map({ $0.id })
    )
    
    static let nfts = [
        Nft(
            id: "1",
            name: "тестовый 1",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"],
            description: "",
            rating: 1,
            price: 12,
            author: ""),
        Nft(
            id: "2",
            name: "тестовый 2",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"],
            description: "",
            rating: 2,
            price: 23.12,
            author: ""),
        Nft(
            id: "3",
            name: "тестовый 3",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"],
            description: "",
            rating: 3,
            price: 45.43,
            author: ""),
        Nft(
            id: "4",
            name: "тестовый 4",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"],
            description: "",
            rating: 4,
            price: 5.4,
            author: ""),
        Nft(
            id: "5",
            name: "тестовый 5",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"],
            description: "",
            rating: 5,
            price: 45.43,
            author: ""),
        Nft(
            id: "6",
            name: "тестовый 6",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"],
            description: "",
            rating: 0,
            price: 3.43,
            author: ""),
        Nft(
            id: "7",
            name: "тестовый 7",
            images: ["https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"],
            description: "",
            rating: 1,
            price: 8.49,
            author: "")
    ]
    
    static let currencies: [Currency] = [
        Currency(
            id: "1",
            title: "Bitcoin",
            name: "ВТС",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Bitcoin_(BTC).png")
        ),
        Currency(
            id: "2",
            title: "Dogecoin",
            name: "DOGE",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Dogecoin_(DOGE).png")
        ),
        Currency(
            id: "3",
            title: "Tether",
            name: "USDT",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Tether_(USDT).png")
        ),
        Currency(
            id: "4",
            title: "Apecoin",
            name: "APE",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/ApeCoin_(APE).png")
        ),
        Currency(
            id: "5",
            title: "Solana",
            name: "SOL",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Solana_(SOL).png")
        ),
        Currency(
            id: "6",
            title: "Ethereum",
            name: "ETH",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Ethereum_(ETH).png")
        ),
        Currency(
            id: "7",
            title: "Cardano",
            name: "ADA",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Cardano_(ADA).png")
        ),
        Currency(
            id: "8",
            title: "Shiba Inu",
            name: "SHIB",
            image: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Shiba_Inu_(SHIB).png")
        ),
    ]
}
