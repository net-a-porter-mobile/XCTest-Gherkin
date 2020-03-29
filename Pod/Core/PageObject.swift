import XCTest

/// Base class for PageObject pattern.
open class PageObject: NSObject {
    required public override init() {
        super.init()
        let presented = isPresented()
        XCTAssertTrue(presented, "\(type(of: self).name) is not presented")
    }

    /// Name of the screen (or its part) that this page object represent.
    /// Default is name of this type without "PageObject" suffix, if any.
    open class var name: String {
        let name = String(describing: self)
        if name.lowercased().hasSuffix("pageobject") {
            return String(name.dropLast(10)).humanReadableString
        }
        return name.humanReadableString
    }

    /// This method should be overriden by subclasses
    /// and should return `true` if this PageObject's screen is presented
    open func isPresented() -> Bool { fatalError("not implemented") }
}

/// This type defines common steps for all page objects.
public class CommonPageObjectsStepDefiner: StepDefiner {

    /// Format for step expression that validates that PageObject is presented
    /// Default value matches "I see %@", "I should see %@" or "it is %@" with optional "the" before page object name
    public static var isPresentedStepFormat = "^(?:I (?:should )?see|it is) (?:the )?%@$"

    override public func defineSteps() {
        allSubclassesOf(PageObject.self).forEach { (subclass) in
            guard subclass != PageObject.self else { return }

            let name = subclass.name
            let expression = String(format: CommonPageObjectsStepDefiner.isPresentedStepFormat, name)
            step(expression) {
                _ = subclass.init()
            }
        }
    }
}
