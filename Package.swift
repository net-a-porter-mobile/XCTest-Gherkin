// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "XCTest_Gherkin",
    products: [
        .library(
            name: "XCTest_Gherkin",
            targets: ["XCTest_Gherkin"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "XCTest_Gherkin_ObjC",
            dependencies: [],
            path: "Pod",
            exclude: [
                "Core/Background.swift",
                "Core/ClassHelperMethods.swift",
                "Core/Example.swift",
                "Core/LevenshteinDistance.swift",
                "Core/MatchedStringRepresentable.swift",
                "Core/PageObject.swift",
                "Core/Step.swift",
                "Core/StepDefiner.swift",
                "Core/StringGherkinExtension.swift",
                "Core/XCTestCase+Gherkin.swift",
                "Native/Language.swift",
                "Native/NativeExample.swift",
                "Native/NativeFeature.swift",
                "Native/NativeFeatureParser.swift",
                "Native/NativeRunner.swift",
                "Native/NativeScenario.swift",
                "Native/NativeTestCase.swift",
                "Native/ParseState.swift",
                "Native/gherkin-languages.json"
            ],
            sources: [
                "Core/UnusedStepsTracker.h",
                "Core/UnusedStepsTracker.m",
                "Native/XCGNativeInitializer.h",
                "Native/XCGNativeInitializer.m"
            ],
            cSettings: [
                .headerSearchPath("Core"),
                .headerSearchPath("Native")
            ]
        ),
        .target(
            name: "XCTest_Gherkin",
            dependencies: [
                "XCTest_Gherkin_ObjC"
            ],
            path: "Pod",
            exclude: [
                "Core/UnusedStepsTracker.h",
                "Core/UnusedStepsTracker.m",
                "Native/XCGNativeInitializer.h",
                "Native/XCGNativeInitializer.m"
            ],
            sources: [
                "Core/Background.swift",
                "Core/ClassHelperMethods.swift",
                "Core/Example.swift",
                "Core/LevenshteinDistance.swift",
                "Core/MatchedStringRepresentable.swift",
                "Core/PageObject.swift",
                "Core/Step.swift",
                "Core/StepDefiner.swift",
                "Core/StringGherkinExtension.swift",
                "Core/XCTestCase+Gherkin.swift",
                "Native/Language.swift",
                "Native/NativeExample.swift",
                "Native/NativeFeature.swift",
                "Native/NativeFeatureParser.swift",
                "Native/NativeRunner.swift",
                "Native/NativeScenario.swift",
                "Native/NativeTestCase.swift",
                "Native/ParseState.swift"
            ],
            resources: [
                .process("Native/gherkin-languages.json")
            ],
            swiftSettings: [
                .define("SWIFT_PACKAGE")
            ])
    ]
)
