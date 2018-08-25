#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "UnusedStepsTracker.h"
#import "XCGNativeInitializer.h"
#import "XCTest_Gherkin.h"

FOUNDATION_EXPORT double XCTest_GherkinVersionNumber;
FOUNDATION_EXPORT const unsigned char XCTest_GherkinVersionString[];

