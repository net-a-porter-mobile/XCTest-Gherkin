//
//  XCGNativeInitializer.m
//  Pods-XCTest-Gherkin_Example
//
//  Created by Kerr Marin Miller on 2017-10-08.
//

#import "XCGNativeInitializer.h"

@implementation XCGNativeInitializer

+ (void)initialize {
    [super initialize];

    if (self == [XCGNativeInitializer class]) {
        return;
    }

    [self processFeatures];
}

+ (void)processFeatures {
    // NO-OP
}

@end
