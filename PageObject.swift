/// Base class for PageObject pattern.
open class PageObject: NSObject {
    required public override init() {
        super.init()
        XCTAssertTrue(isPresented(), "\(type(of: self).name) is not presented")
    }

    /// Name of the screen (or its part) that this page object represent
    open static var name: String {
        let name = String(describing: self)
        if name.lowercased().hasSuffix("pageobject") {
            return String(name.dropLast(10))
        }
        return name
    }

    /// This method should be overriden by subclasses
    /// and should return `true` if this PageObject's screen is presented
    open func isPresented() -> Bool { fatalError("not implemented") }
}

/// This type defines common steps for all page objects.
public class CommonPageObjectsStepDefiner: StepDefiner {

    /// Format for step expression that validates that PageObject is presented
    /// Default value is "I see %@"
    public static var isPresentedStepFormat = "I see %@"

    override public func defineSteps() {
        allSubclassesOf(PageObject.self).forEach { (subclass) in
            guard subclass != PageObject.self else { return }

            let name = subclass.name.humanReadableString
            let expression = String(format: CommonPageObjectsStepDefiner.isPresentedStepFormat, name)
            step(expression) {
                _ = subclass.init()
            }
        }
    }
}