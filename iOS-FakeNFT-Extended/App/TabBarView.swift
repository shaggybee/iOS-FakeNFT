import SwiftUI

struct TabBarView: View {
    let services = ServicesAssemblyMock()
    
    var body: some View {
        TabView {
            Text("Профиль")
                .tabItem {
                    Label {
                        Text("Профиль")
                    } icon: {
                        Image(.profile30)
                    }
                }
            
            Text("Каталог")
                .tabItem {
                    Label {
                        Text("Каталог")
                    } icon: {
                        Image(.catalog30)
                    }
                }
            
            // TODO как будет доступен API не забыть удалить и прокинуть действительный
            ShoppingCartRootView(services: services)
                .tabItem {
                    Label {
                        Text("Tab.cart")
                    } icon: {
                        Image(.basket30)
                    }
                }
            
            Text("Статистика")
                .tabItem {
                    Label {
                        Text("Статистика")
                    } icon: {
                        Image(.statistics30)
                    }
                }
        }
        .tint(.blueUniversal)
    }
}
