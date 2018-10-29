//
//  UnusedStepsTracker.m
//  XCTest-Gherkin
//
//  Created by Ilya Puchka on 25/08/2018.
//

#import "UnusedStepsTracker.h"

@interface UnusedStepsTracker() <XCTestObservation>
@property (nonatomic, strong) NSMutableSet<NSString *> *allSteps;
@property (nonatomic, strong) NSMutableSet<NSString *> *executedSteps;
// XCTest can invoke callbacks several times,
// when this counter reaches 0 the test run actually finished
@property (nonatomic, assign) NSInteger bundleCounter;
@end

@implementation UnusedStepsTracker

+ (void)initialize {
    [super initialize];
    [UnusedStepsTracker shared];
}

+ (instancetype)shared {
    static UnusedStepsTracker* shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        shared.allSteps = [NSMutableSet new];
        shared.executedSteps = [NSMutableSet new];
        shared.bundleCounter = 0;
        [[XCTestObservationCenter sharedTestObservationCenter] addTestObserver: shared];
    });
    return shared;
}

- (NSArray<NSString *> *)steps {
    return self.allSteps.allObjects;
}

- (void)setSteps:(NSArray<NSString *> *)steps {
    [self.allSteps addObjectsFromArray:steps];
}

-(void)performedStep:(NSString *)step {
    [self.executedSteps addObject:step];
}

- (void)testBundleWillStart:(NSBundle *)testBundle {
    self.bundleCounter++;
}

- (void)testBundleDidFinish:(NSBundle *)testBundle {
    self.bundleCounter--;
    if (self.bundleCounter == 0) {
        NSMutableSet *unusedSteps = self.allSteps;
        [unusedSteps minusSet: self.executedSteps];
        if (unusedSteps.count > 0) {
            self.printUnusedSteps(unusedSteps.allObjects);
        }
    }
}

@end
