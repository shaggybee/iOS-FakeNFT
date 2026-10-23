import SwiftUI

@main
struct AppRootView: App {
    
    init() {
        configTabBar()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl()))
        }
    }
    
    private func configTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .whitePrimary
        appearance.shadowColor = .clear
        
        appearance.stackedLayoutAppearance.normal.iconColor = .blackPrimary
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(resource: .blackPrimary)]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
