import Foundation

enum ProfileDataMode {
    case live
    case demo
    case uiTesting

    static var current: Self {
        #if DEBUG
        return debugMode(arguments: ProcessInfo.processInfo.arguments)
        #else
        return .live
        #endif
    }

    #if DEBUG
    static func debugMode(arguments: [String]) -> Self {
        if arguments.contains("--profile-ui-testing") { return .uiTesting }
        if arguments.contains("--profile-live-api") { return .live }
        return .demo
    }
    #endif
}
