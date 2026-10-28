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
            image: Bundle.main.url(forResource: "bitcoin32", withExtension: "png")
        ),
        Currency(
            id: "2",
            title: "Dogecoin",
            name: "DOGE",
            image: Bundle.main.url(forResource: "dogecoin32", withExtension: "png")
        ),
        Currency(
            id: "3",
            title: "Tether",
            name: "USDT",
            image: Bundle.main.url(forResource: "tether32", withExtension: "png")
        ),
        Currency(
            id: "4",
            title: "Apecoin",
            name: "APE",
            image: Bundle.main.url(forResource: "apeCoin32", withExtension: "png")
        ),
        Currency(
            id: "5",
            title: "Solana",
            name: "SOL",
            image: Bundle.main.url(forResource: "solana32", withExtension: "png")
        ),
        Currency(
            id: "6",
            title: "Ethereum",
            name: "ETH",
            image: Bundle.main.url(forResource: "etherium32", withExtension: "png")
        ),
        Currency(
            id: "7",
            title: "Cardano",
            name: "ADA",
            image: Bundle.main.url(forResource: "cardano32", withExtension: "png")
        ),
        Currency(
            id: "8",
            title: "Shiba Inu",
            name: "SHIB",
            image: Bundle.main.url(forResource: "shibaInu32", withExtension: "png")
        ),
    ]
}
