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
        
        appearance.stackedLayoutAppearance.normal.iconColor = .blackPrimary
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(resource: .blackPrimary)]
        
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
