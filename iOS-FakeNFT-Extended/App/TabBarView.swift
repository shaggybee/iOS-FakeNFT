import SwiftUI

struct TabBarView: View {
    @Environment(ServicesAssembly.self) private var servicesAssembly
    @State private var selectedTab: Tab = .catalog
    @State private var catalogRouter = CatalogRouter()

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
                    collectionsService: servicesAssembly.collectionsService,
                    router: catalogRouter
                ),
                router: catalogRouter,
                makeCollectionViewModel: { [catalogRouter, servicesAssembly] collectionId in
                    CollectionViewModel(
                        collectionId: collectionId,
                        collectionService: servicesAssembly.collectionService,
                        nftService: servicesAssembly.nftService,
                        likesService: servicesAssembly.likesService,
                        cartService: servicesAssembly.cartService,
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
            
            // TODO как будет доступен API не забыть удалить и прокинуть действительный
            ShoppingCartRootView(shoppingCartService: ServicesAssemblyMock().shoppingCartService)
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
