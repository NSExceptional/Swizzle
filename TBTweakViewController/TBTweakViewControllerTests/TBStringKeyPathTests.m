//
//  TBStringKeyPathTests.m
//  TBTweakViewController
//
//  Created by Tanner on 3/26/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+KeyPaths.h"


@interface TBStringKeyPathTests : XCTestCase
@end

@implementation TBStringKeyPathTests

- (void)testKeyPathCategory {
    NSArray *tests = @[@[@"Bu", @"Bundle", @"Bundle."],
                       @[@"*ndle", @"Bundle", @"Bundle."],
                       @[@"Bundle.", @"class", @"Bundle.class."],
                       @[@"Bundle.cla", @"class", @"Bundle.class."],
                       @[@"Bundle.*ass", @"class", @"Bundle.class."],
                       @[@"UIKit\\.frame", @"UIKit.framework", @"UIKit\\.framework."],
                       @[@"UIKit++\\.frame", @"UIKit++.framework", @"UIKit++\\.framework."],
                       @[@"UIKit\\.framework.*ass", @"class", @"UIKit\\.framework.class."],
                       @[@"UIKit\\.framework.cool\\.class.met", @"method:", @"UIKit\\.framework.cool\\.class.method:."]];

    for (NSArray<NSString*> *test in tests) {
        XCTAssertEqualObjects([test[0] stringByReplacingLastKeyPathComponent:test[1]], test[2]);
    }
}

@end
