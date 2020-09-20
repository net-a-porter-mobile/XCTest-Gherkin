# XCTest-Gherkin

[![CI Status](http://img.shields.io/travis/net-a-porter-mobile/XCTest-Gherkin.svg?style=flat)](https://travis-ci.org/net-a-porter-mobile/XCTest-Gherkin.svg?branch=master)
[![Version](https://img.shields.io/cocoapods/v/XCTest-Gherkin.svg?style=flat)](http://cocoapods.org/pods/XCTest-Gherkin)
[![License](https://img.shields.io/cocoapods/l/XCTest-Gherkin.svg?style=flat)](http://cocoapods.org/pods/XCTest-Gherkin)
[![Platform](https://img.shields.io/cocoapods/p/XCTest-Gherkin.svg?style=flat)](http://cocoapods.org/pods/XCTest-Gherkin)

# XCTest+Gherkin
At net-a-porter we have traditionally done our UI testing using Cucumber and Appium, which has worked fine and did the job. However, it has a few disadvantages; it requires knowing another language (in our case Ruby), it requires more moving parts on our CI stack (cucumber, node, appium, ruby, gems etc), it ran slowly, and it always seemed to lag a bit behind the latest Xcode tech. None of these by themselves are deal breakers but put together it all adds up to make UI testing more of a chore than we think it should be.

The goals of this project are to

1. Increase speed and reduce tech overhead of writing UI tests, with the end goal of developers sitting with testers and writing UI tests when they write unit tests. These tests would be run by our CI on each merge so they have to be fast.
2. Not lose any of the existing test coverage. We've been using Appium for a while so we've built up a good set of feature files that cover a big chunk of functionality which we don't want to lose.

Goal #1 is easy to achieve; we just use a technology built into Xcode so we have a common technology between the tests and the app, using a common language our developers and testers both know.

Goal #2 is tricker - we will need to keep our .feature files and move them over to the new system somehow. The structure of our tests should be as similar to Cucumber's structure as possible to reduce the learning curve; we're already asking to testers to learn a new language!

The solution was to extend `XCTestCase` to allow Gherkin style syntax when writing tests, like this:

### Features
```swift
import XCTest
import XCTest_Gherkin

class testAThingThatNeedsTesting: XCTestCase {
    func testBasicSteps() {
        Given("A situation that I want to start at")
        When("I do a thing")
        And("I do another thing")
        Then("This value should be 100")
        And("This condition should be met as well")
    }
}
```

This is a valid test case that should run inside Xcode, with the failing line highlighted and the tests appearing in the test inspector pane. An important thing to keep is visibility of which test failed and why!

### Step definitions
The next step is to write step definitions for each of these steps. Here's two of them:

```swift
class SomeStepDefinitions : StepDefiner {  
    override func defineSteps() {
        step("A situation that I want to start at") {
            // Your setup code here
        }

        step("This value should be ([0-9]*)") { (matches: [String]) in
            let expectedValue = matches.first!
            let someValueFromTheUI = /* However you want to get this */
            XCTAssertEqual(expectedValue, someValueFromTheUI)
        }
    }
}
```

These steps match (via regular expressions, using **case insensitive** `NSRegularExpression`) and return the capture groups (if there are any). The second step will capture the digits from the end of the test and compare it to the current state of the UI.

There are convenience versions of the step method which extract the first match for you:

```swift
step("This value should be ([0-9]*)") { (match: String) in
    XCTAssertEqual(expectedValue, match)
}

step("This value should be between ([0-9]*) and ([0-9]*)") { (match1: String, match2: String) in
    let someValue = /* However you want to get this */
    XCTAssert(someValue > match1)
    XCTAssert(someValue < match2)
}
```

### Captured value types
In step definition with captured values you can use any type conforming to `MatchedStringRepresentable`. `String`, `Double`, `Int` and `Bool` types already conform to this protocol. You can also match your custom types by conforming them to `CodableMatchedStringRepresentable`. This requires type to implement only `Codable` protocol methods, `MatchedStringRepresentable` implementation is provided by the library.

```swift
struct Person: Codable, Equatable {
  let name: String
}
extension Person: CodableMatchedStringRepresentable {
}

step("User is logged in as (.+)") { (match: Person) in
    let loggedInUser = ...
    XCTAssertEqual(loggedInUser, match)
}

func testLoggedInUser() {
    let nick = Person(name: "Nick")
    Given("User is loggeed in as \(nick)")
}
```

### Named capture groups
On iOS 11 and macOS 10.13 you can use named capture groups to improve your console and activity logs. The name of the group will be transformed to human readable form and will replace the step expression substring that it captures. This is particularly useful when you use your custom types as step parameters as described in the previous section.

Without named capture groups such test

```swift
step("User is logged in as (.+)") { (match: Person) in ... }

func testLoggedInUser() {
    let nick = Person(name: "Nick")
    Given("User is loggeed in as \(Person(name: "Nick"))")
}
```

will produce following logs:

```
step User is loggeed in as {"name":"Nick"}
```

With named capture groups the step definition can look like this (notice that `match` is now a `StepMatches<Person>`)

```swift
step("User is logged in as (?<aRegisteredUser>.+)") { (match: StepMatches<Person>) in ... }
```

and the same test will produce logs:

```
step User is logged in as a registered user
```

In step implementation you will access matched values using the name of the group, i.e. `match["aRegisteredUser"]`. You can access all matched values (including matched by unnamed groups) by their index, starting from 0, i.e. `match[0]`. So you can have more than one named group and you can mix them with unnamed groups.

### Examples and feature outlines
If you want to test the same situation with a set of data, Gherkin allows you to specify example input for your tests. We used this all over our previous tests so we needed to deal with it here too!

```swift
func testOutlineTests() {
    Examples(
        [ "name", "age" ],
        [ "Alice", "20" ],
        [ "Bob", "20" ]
    )

    Outline {
        Given("I use the example name <name>")
        Then("The age should be <age>")
    }
}
```

This will run the tests twice, once with the values `Alice,20` and once with the values `Bob,20`.

The easiest way to use `Examples` and `Outline` functions is to call `Examples` before `Outline`. But in Gherkin feature files Examples always go after Scenario Outline. If you want to keep this order in native tests (and don't care about little bit funky Xcode indentation) you can provide examples after defining Outline via trailing closure or explicit `Examples` parameter:

```swift
func testOutlineTests() {
    Outline({
        Given("I use the example name <name>")
        Then("The age should be <age>")
    }) {
        [
            [ "name" , "age", "height" ],
            [ "Alice", "20" , "170"    ],
            [ "Bob"  , "20" , "170"    ]
        ]
    }
        
    // or
    
    Outline({
        Given("I use the example name <name>")
        Then("The age should be <age>")
    }, examples: 
        [
            [ "name" , "age", "height" ],
            [ "Alice", "20" , "170"    ],
            [ "Bob"  , "20" , "170"    ]
        ]
    )
}
```

### Background
If you are repeating the same steps in each scenario you can move them to a `Background`. A `Background` is run before each scenario (effectively just before first scenario step is execuated) or outline pass (but **after** `setUp()`). You can have as many steps in `Background` as you want.

```swift
class OnboardingTests: XCTestCase {

    func Background() {
        Given("I launch the app")
    }

    func testOnboardingIsDisplayed() {
        Then("I see onboarding screen")
    }

    func testOnboardingIsDisplayedEachTime() {
        Examples([""], ["1"], ["2"])

        Outline {
            Then("I see onboarding screen")
            And("I kill the app")
        }
    }

}

```

### Page Object
Built in `PageObject` type can be used as a base type for your own page objects. It will assert that its `isPresented()`, that you should override, returnes `true` when instance of it is created. It aslo defines a `name` property which by default is the name of the type without `PageObject` suffix, if any.  

`PageObject` also comes with some predefined steps, defined by `CommonPageObjectsStepDefiner`, which validate that this page object is displayed, with formats `I see %@`, `I should see %@` and `it is %@` with optional `the` before page object name parameter.

### Dealing with errors / debugging tests

#### Missing steps

If there isn't a step definition found for a step in your feature file then the extensions will output a list of all the available steps and then fail the test, something like:

```
steps
-------------
/I have a working Gherkin environment/  (SanitySteps.swift:17)
/I use the example name (?:Alice|Bob)/  (SanitySteps.swift:38)
/The age should be ([0-9]*)/  (SanitySteps.swift:44)
/This is another step/  (SanitySteps.swift:33)
/This step should call another step/  (SanitySteps.swift:28)
/This test should not ([a-zA-Z0-9]*)/  (SanitySteps.swift:23)
-------------
XCTestCase+Gherkin.swift:165: error: -[XCTest_Gherkin_Tests.ExampleFeatures testBasicSteps] : failed - Step definition not found for 'I have a working Pickle environment'
```

#### Ambiguous steps

Sometimes, multiple steps might contain the same text. The library will match with what it thinks is the right step, but it might get it wrong. For example if you have these step definitions:

```swift
step("email button") { ... }
step("I tap the email button") { ... }
```

When you try to run this Given

```swift
func testStepAnchorMatching() {
    Given("I tap the email button")
}
```

it might match against the "email button" step, instead of the "I tap the email button" step. To fix this, there are two options.

1. You can pass an exact string literal to the step definition instead of using the normal method, which treats everything as a regular expression.

```swift
step(exactly: "I tap the email button")
```

This will match _only_ the exact text "I tap the email button". Any regular expression special characters in this string will be matched exactly.

2. You can anchor the regular expression to the start and end of the string using `^` and `$`, like this:

```swift
step("^email button$") { ... }
step("I tap the email button") { ... }
```

Now, "I tap the email button" doesn't match the first step.

This method is useful if you need to match ambiguous steps, but can't use approach (1) because you also need other features of regular expressions (i.e. pattern matching etc)


### Screenshots

It's useful to have screenshots of failing UI tests, and this can be configured with the

```
XCTestCase.setAutomaticScreenshotsBehaviour([.onFailure, .beforeStep, .afterStep],
                                            quality: .medium,
                                            lifetime: .deleteOnSuccess)
```  

## Installation

### CocoaPods
XCTest-Gherkin is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'XCTest-Gherkin'
```

and run `pod install`

### Carthage
XCTest-Gherkin is also available through [Carthage](https://github.com/Carthage/Carthage). To install it, simply add the following line to your Cartfile:
```
github "net-a-porter-mobile/XCTest-Gherkin" == 0.13.2
```

and run `carthage bootstrap --platform iOS`. The generated framework is named `XCTest_Gherkin.framework`.

### Swift Package Manager
In your Xcode project add XCTest-Gherkin via the File -> Swift Packages -> Add package dependency... menu.

Note that Xcode 12 and Swift 5.3 is a minimum requirement for using XCTest-Gherkin in combination with Swift Package Manager.

## Configuration

No configuration is needed.

## Examples
There are working examples in the pod's Example project - just run the tests and see what happens!

# Native feature file parsing
To help with moving from native feature files (we have lots of these from our previous test suite) to working in Swift, it would be handy to be able to parse the current feature files without having to modify them into their Swift counterparts.

This is also useful when they are first being written by product owners who know Given/When/Then syntax but aren't Swift developers :)

If you include the `Native` subpod in your podfile

```ruby
pod 'XCTest-Gherkin/Native'
```

you will also include the ability to parse true Gherkin syntax feature files and have the libary create runtime tests from them.

There is an example of this in the Example/ project as part of this pod. Look at the `ExampleNativeTest` class - all you need to do is specify the containing folder and all the feature files in that folder will be read.

The advantages of this are obvious; you get to quickly run your existing feature files and can get up and running quickly. The disadvanages are beacuse the tests are generated at runtime they can't be run individually from inside Xcode so debugging is tricker. I would use this to start testing inside Xcode but if it gets hairy, convert that feature file into a native Swift test and debug from there.


### Localisation of feature files

You can use feature files written in multiple languages. To set the language of a feature file put a `# language: en` with appropriate language code at the first line of a feature file. By default English localisation is used. You can see all available localisations in `gherkin-languages.json` file or from code using `NativeTestCase.availableLanguages` property. Here is an example of a feature file in Russian:

```
# language: ru
Функция: Разбор простого функционального файла

    Сценарий: Это очень простой пример успешного сценария
        Допустим Я имею рабочее окружение Gherkin
        Тогда этот тест не должен завершиться ошибкой
```


### Disclaimer
The Gherkin syntax parser here isn't really production ready - it's certainly not a validator and will probably happily parse malformed Gherkin files quite happily. The feature files it's parsing are assumed to be fairly well constructed. The purpose of this subpod is to help migrate from old feature files into the Swift way of doing things so that's all it does. Feel free to submit pull requests if you want to change this :)


## XCTest+Gherkin at net-a-porter

We use this extension along with KIF to do our UI tests. For unit tests we just use XCTest plain. KIF is working really well for us, and is far far faster than our previous test suite.

We put our calls to KIF inside our step definitions, which happens to closely mirror how we worked with our previous Cucumber implementation, making migrating even easier.

## Author

Sam Dean, deanWombourne@gmail.com

## License

See LICENSE for details - it's the Apache license.
