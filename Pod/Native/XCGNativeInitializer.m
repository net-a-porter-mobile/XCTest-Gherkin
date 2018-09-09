//
//  XCGNativeInitializer.m
//  Pods-XCTest-Gherkin_Example
//
//  Created by Kerr Marin Miller on 2017-10-08.
//

#import "XCGNativeInitializer.h"
#import "UnusedStepsTracker.h"

@implementation XCGNativeInitializer

+ (void)initialize {
    [super initialize];
    // XCGNativeInitializer is always a principal class when Native is linked
    // so we use it to startup observer
    [UnusedStepsTracker initialize];

    // We don't want to process any features for this class.
    if (self == [XCGNativeInitializer class]) {
        return;
    }

    [self processFeatures];
}

+ (void)processFeatures {
    NSAssert(NO, @"This is meant to be overridden by NativeTestCase and should never be called.");
}

@end
