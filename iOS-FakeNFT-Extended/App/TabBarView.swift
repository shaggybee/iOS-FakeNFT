import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: Tab = .catalog
    @State private var catalogRouter = CatalogRouter()
    
    let services = ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl())
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Tab.profile")
                .tabItem {
                    Label {
                        Text("Tab.profile")
                    } icon: {
                        Image(.profile30)
                    }
                }
                .tag(Tab.profile)
            
            CatalogView(
                viewModel: CatalogViewModel(
                    collectionsService: services.collectionsService,
                    router: catalogRouter
                ),
                router: catalogRouter,
                makeCollectionViewModel: { [catalogRouter, services] collectionId in
                    CollectionViewModel(
                        collectionId: collectionId,
                        collectionService: services.collectionService,
                        nftService: services.nftService,
                        likesService: services.likesService,
                        cartService: services.cartService,
                        router: catalogRouter
                    )
                }
            )
            .tabItem {
                Label {
                    Text("Tab.catalog")
                } icon: {
                    Image(.catalog30)
                }
            }
            .tag(Tab.catalog)
            
            ShoppingCartRootView(services: services)
                .tabItem {
                    Label {
                        Text("Tab.cart")
                    } icon: {
                        Image(.basket30)
                    }
                }
                .tag(Tab.cart)
            
            Text("Tab.statistics")
                .tabItem {
                    Label {
                        Text("Tab.statistics")
                    } icon: {
                        Image(.statistics30)
                    }
                }
                .tag(Tab.statistics)
        }
        .tint(.blueUniversal)
    }
}

private extension TabBarView {
    enum Tab: Hashable {
        case profile
        case catalog
        case cart
        case statistics
    }
}
