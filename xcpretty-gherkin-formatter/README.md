# XCPretty Gherkin Formatter

Custom formatter for [xcpretty](https://github.com/supermarin/xcpretty) with some syntactic highlighting for BDD tests written with Gherkin language using XCTest-Gherkin framework. [Here is example of output]().

## Usage

```bash
#!/bin/bash

xcodebuild | xcpretty -f `<path-to-xcpretty-gherkin-formatter>/bin/xcpretty-gherkin-formatter`
```