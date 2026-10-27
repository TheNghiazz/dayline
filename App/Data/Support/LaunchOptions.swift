import Foundation

/// Cờ truyền vào khi launch, dùng cho CI screenshot và UI test.
struct LaunchOptions {
    var seedData: Bool = false
    var resetData: Bool = false
    var locale: String?

    static var current: LaunchOptions {
        let arguments = ProcessInfo.processInfo.arguments
        return LaunchOptions(
            seedData: arguments.contains("-uiTestSeed"),
            resetData: arguments.contains("-uiTestReset"),
            locale: value(after: "-uiTestLocale", in: arguments)
        )
    }

    private static func value(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag),
              arguments.indices.contains(index + 1) else { return nil }
        return arguments[index + 1]
    }
}
