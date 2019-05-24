//
//  UnusedStepsTracker.h
//  XCTest-Gherkin
//
//  Created by Ilya Puchka on 25/08/2018.
//

#import <XCTest/XCTest.h>

/// Class used internally to detect unused steps.
/// Note: without being a subclass of XCTestCase this class will not be initialised before tests start
@interface UnusedStepsTracker: XCTestCase

@property (nonatomic, strong) void (^ _Nullable printUnusedSteps)(NSArray<NSString*> * _Nonnull);

+ (instancetype _Nonnull)shared;
- (void)setSteps:(NSArray<NSString *> * _Nonnull)steps;
- (void)performedStep:(NSString * _Nonnull)step;

@end
