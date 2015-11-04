import UIKit
import XCTest
import XCTest_Gherkin

class ExampleTests: XCTestCase {

    func testBasicSteps() {
        Given("I have a working Gherkin environment")
        Then("This test should not fail")
    }
    
    func testNestedSteps() {
        Given("This step should call another step")
        Then("This test should not fail")
    }
    
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
    
}
