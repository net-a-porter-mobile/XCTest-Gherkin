//
//  UnusedStepsTracker.h
//  XCTest-Gherkin
//
//  Created by Ilya Puchka on 25/08/2018.
//

#import <XCTest/XCTest.h>

/// Class used internally to detect unused steps
@interface UnusedStepsTracker: NSObject

@property (nonatomic, strong) void (^printUnusedSteps)(NSArray<NSString*> * _Nonnull);

+ (instancetype)shared;
- (void)start;
- (void)setSteps:(NSArray<NSString *> *)steps;
- (void)performedStep:(NSString *)step;

@end
