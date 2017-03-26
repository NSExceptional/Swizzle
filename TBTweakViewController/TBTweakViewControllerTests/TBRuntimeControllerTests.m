//
//  TBRuntimeControllerTests.m
//  TBTweakViewController
//
//  Created by Tanner on 3/26/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBKeyPathTokenizer.h"
#import "TBRuntimeController.h"

#import <XCTest/XCTest.h>

@interface TBRuntimeControllerTests : XCTestCase
@end

@implementation TBRuntimeControllerTests

- (void)testThatBitch {
    NSDictionary *tests = @{@"UIKit\\.framework.": @100,
                            @"UIKit\\.framework.UIView.-": @50,
                            @"UIKit\\.framework.UIView.-fr": @0,
                            @"UIKit\\.framework.UIView.+anim": @0};
    for (NSString *test in tests) {
        TBKeyPath *keyPath = [TBKeyPathTokenizer tokenizeString:test];
        XCTAssertGreaterThan([TBRuntimeController dataForKeyPath:keyPath].count, [tests[test] intValue]);
    }
}

@end
