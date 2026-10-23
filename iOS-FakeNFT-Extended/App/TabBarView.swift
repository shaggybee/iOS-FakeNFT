import SwiftUI

struct TabBarView: View {
    @Environment(ServicesAssembly.self) private var servicesAssembly
    @State private var selectedTab: Tab = .catalog

    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Профиль")
                .tabItem {
                    Label {
                        Text("Профиль")
                    } icon: {
                        Image(.profile30)
                    }
                }
                .tag(Tab.profile)
            
            // TODO: вернуть servicesAssembly.collectionsService, когда API станет доступен
            CatalogView(viewModel: CatalogViewModel(collectionsService: CollectionsServiceStub()))
                .tabItem {
                    Label {
                        Text("Каталог")
                    } icon: {
                        Image(.catalog30)
                    }
                }
                .tag(Tab.catalog)
            
            Text("Корзина")
                .tabItem {
                    Label {
                        Text("Корзина")
                    } icon: {
                        Image(.basket30)
                    }
                }
                .tag(Tab.cart)
            
            Text("Статистика")
                .tabItem {
                    Label {
                        Text("Статистика")
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
