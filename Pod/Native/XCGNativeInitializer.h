//
//  XCGNativeInitializer.h
//  Pods
//
//  Created by Kerr Marin Miller on 2017-10-08.
//

#import <XCTest/XCTest.h>

/// The internal base class that provides the mechanism
/// to dynamically create new test classes from feature
/// files. It does this by leveraging +initialize.
@interface XCGNativeInitializer : XCTestCase

/// A class method meant to be overridden by NativeTestCase to
/// process the features in each of the native feature files.
+ (void)processFeatures;

@end
