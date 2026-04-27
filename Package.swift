// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ReminderMenu",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "ReminderMenu", targets: ["ReminderMenu"])
    ],
    targets: [
        .executableTarget(
            name: "ReminderMenu",
            path: "ReminderMenu",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("SwiftUI"),
                .linkedFramework("EventKit"),
                .linkedFramework("Carbon")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
