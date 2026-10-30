import SwiftUI

struct TabBarView: View {
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
            
            Text("Корзина")
                .tabItem {
                    Label {
                        Text("Корзина")
                    } icon: {
                        Image(.basket30)
                    }
                }
            NavigationStack {
                StatisticsRatingView()
            }
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
