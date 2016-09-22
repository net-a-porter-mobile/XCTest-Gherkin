#¡ /bin/sh

if [ ! -e "Example/Pods/Pods.xcodeproj/xcshareddata/xcschemes/XCTest-Gherkin.xcscheme" ]
then
    echo "Missing XCTest-Gherkin shared scheme"
    exit 1
fi

