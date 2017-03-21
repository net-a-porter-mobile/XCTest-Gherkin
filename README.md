# XCTest-Gherkin

[![CI Status](http://img.shields.io/travis/net-a-porter-mobile/XCTest-Gherkin.svg?style=flat)](https://travis-ci.org/net-a-porter-mobile/XCTest-Gherkin)
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

These steps match (via regular expressions, using `NSRegularExpression` obvs) and return the capture groups (if there are any). The second step will capture the digits from the end of the test and compare it to the current state of the UI.

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

NB The examples have to be defined _before_ the `Outline {..}` whereas in Gherkin you specify them afterwards. Sorry about that.

### Dealing with errors / debugging tests

#### Duplicate steps:

If there are step definitions which all match a step in your feature then the test will fail with an error something like 

```
-[XCTest_Gherkin_Tests.ExampleFeatures testBasicSteps] : failed - Multiple steps found for : I have a working Gherkin environment
```

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

## Installation

XCTest-Gherkin is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'XCTest-Gherkin'
```

and run `pod install`

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

### Disclaimer
The Gherkin syntax parser here isn't really production ready - it's certainly not a validator and will probably happily parse malformed Gherkin files quite happily. The feature files it's parsing are assumed to be fairly well constructed. The purpose of this subpod is to help migrate from old feature files into the Swift way of doing things so that's all it does. Feel free to submit pull requests if you want to change this :)


## XCTest+Gherkin at net-a-porter

We use this extension along with KIF to do our UI tests. For unit tests we just use XCTest plain. KIF is working really well for us, and is far far faster than our previous test suite.

We put our calls to KIF inside our step definitions, which happens to closely mirror how we worked with our previous Cucumber implementation, making migrating even easier.

## Author

Sam Dean, sam.dean@net-a-porter.com

## License

See LICENSE for details - it's the Apache license.
