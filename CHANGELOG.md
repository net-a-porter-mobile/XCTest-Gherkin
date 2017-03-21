# XCTest-Gherkin changelog

### Unreleased

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
