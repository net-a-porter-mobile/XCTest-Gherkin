# XCTest-Gherkin changelog

### Unreleased

### 0.21.2
+ Fix for typo in localisation (thanks @nugmanoff)
+ Fix for crash replacing multiple objects (thanks @stefanrenne)

### 0.21.1
+ Support subfolders in native folder parsing (recurse into them)

## 0.21.0
+ Added "But" (thanks @jmp)


## 0.20.0
+ Added package.swift (thanks @t-unit)

### 0.19.2
+ Bugfix for macOS test targets (thanks @cyrusingraham)
+ Fix case where incorrect number of ranges reported (thanks @jcavar)

### 0.19.1

## 0.19.0
+ Update to Swift 5
+ Update to cocoapods 1.7.0
+ Use bundler to help dependency management

## 0.18.0
+ Add `step(exactly: String)` to explicitly exactly match a step instead of using regexes (fixes #142)
+ Add regex options to step definitions (thanks @ilyapuchka)

## 0.17.1
+ fix for name property on PageObject (thanks @ilyapuchka)

## 0.17.0 (all @ilyapuchka)
+ Xcode 10 support
+ Support for named matches
+ Add descriptions to feature files
+ Improvements to logging
+ Feature file localisation support
+ Highlight correct lien in feature files for failing tests
+ Track unused steps
+ Introduce PageObject

## 0.16.0
+ Pass arbitary object in/out of a step (thanks @ilyapuchka)

## 0.15.0
+ Automatically take screenshots of failing tests (thanks @ilyapuchka)

# 0.14.2
+ Show error step location as well as assertion failure location (thanks @ilyapuchka)

# 0.14.1
+ Fix to point step definitions at the current test instance

## 0.14.0
+ Update to Swift 4.1, and validate using cocoapods 1.5.0

### 0.13.2
+ Fix swift 4 warnings about String.characters

## 0.13.1
+ Swift 4

## 0.12
+ Fix for +initialize unavailable in Xcode 9.1 in Swift

## 0.11
+ Wrap execution of each step in XCTContext's runActivity method so we get better logging within Xcode of native Gherkin.

### 0.10.3
+ Fix for crash enumerating all classes to find steps
+ Clearer failure message when step isn't found
+ Allow Double and Bool as closure types in step definitions
+ Allow mix of closure parameter types in step definitions with two matches

### 0.10.2
+ Update .travis.yml to Xcode 8.3
+ Update CocoaPods version in .travis.yml to 1.2.0

### 0.10.1
## 0.10
Please prefer 0.10.2

## 0.9
+ Fix for Xcode 8.2

## 0.8
+ Added Swift 3 and Xcode 8 support
+ XCTestCase setUp and tearDown methods support for NativeTestCase scenarios
+ Improved integration with Xcode Test Navigator

## 0.7
+ Explicitly disable bitcode (thanks @kerrmarin)
+ Better newline handling for features created on other systems (thanks @smaljaar)

## 0.6
+ Added forms of the step definition method with single and double string match parameters
+ Added ability to parse Background gherkin keyword (thanks to @smaljaar)
+ Added ability to create a native test case from a file instead of a directory (thanks @Rabursky)
+ Add ability to specify set up code for native tests (thanks @Rabursky)

### 0.5.1
+ Fix for parsing native feature files with comments / whitespace (thanks to @smaljaar)

## 0.5.0
+ Add better debugging for native feature file migration (thanks to @smaljaar)
+ Remove bitcode post install script from podfile and migrate to pod 1.0.x syntax
+ Add xcode-ui example (and tests)
+ Add OSX as a target in the podspec (thanks to @pat2man)
+ Remove foundation from the strings extensions (thanks to @dfrib)

### 0.4.4
+ Make debug use NSLog instead of print - get thread safety

### 0.4.3
+ Make the print step definitions debug method not need an instance of XCTestCase in scope

### 0.4.2
+ Fixed another issue in camelcaseify, added tests

### 0.4.1
+ Fixed bug in camelcaseify function, added tests

## 0.4.0
+ Add shared examples

### 0.3.3
+ Fix crash when steps contain optional matching groups and one of them doesn't match

### 0.3.2
+ printing the steps is case-insensitive order

### 0.3.1
+ Calling printStepDefinitions now returns the steps even if you haven't run any yet. Previously this would only output the steps after the first step had run

## 0.3
+ Make console color default disabled
+ Allow concurrent tests to work using associated objects instead of global state

## 0.2
+ Add support for native feature files

## 0.1
+ Initial release
