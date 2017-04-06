//
//  TBTweakViewControllerTests.m
//  TBTweakViewControllerTests
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TBTweak.h"
#import "NSTestClass.h"
#import "NSObject+Reflection.h"

#define Hook(target, sel, inst) [TBMethodHook hook:[MKLazyMethod methodForSelector:@selector(sel) class:[target class] instance:inst]]
#define Tweak(target, sel, inst) TBTweak *tweak = [TBTweak tweakWithTitle:@"Test tweak"]; \
[tweak addHook:Hook(target, sel, inst)]; \
TBMethodHook *hook = tweak.hooks.firstObject

@interface TBTweakViewControllerTests : XCTestCase
@property (nonatomic) NSTestClass *testInstance;
@property (nonatomic) TBTweak *tweak;
@end

@implementation TBTweakViewControllerTests

- (void)setUp {
    self.tweak = [TBTweak tweakWithTitle:@"Test tweak"];
    self.testInstance = [NSTestClass new];
    self.testInstance.name      = @"foo";
    self.testInstance.length    = 3;
    self.testInstance.frame     = CGRectMake(1, 1, 1, 1);
    self.testInstance.center    = CGPointMake(2, 2);
    self.testInstance.character = 'a';
}

- (void)testBasics {
    // Tweak
    Tweak(NSTestClass, length, YES);
    XCTAssertFalse(tweak.enabled);
    
    // Hook
    XCTAssertTrue(hook.canOverrideReturnValue);
    XCTAssertFalse(hook.canOverrideAllArgumentValues);
    XCTAssertEqual(hook.method.signature.numberOfArguments, 2);
    XCTAssertEqualObjects(hook.target, @"NSTestClass");
    XCTAssertFalse(hook.isClassMethod);
    
    // Method
    MKMethod *same = [MKMethod methodForSelector:@selector(length) class:[NSTestClass class] instance:YES];
    XCTAssertEqualObjects(hook.method.typeEncoding, same.typeEncoding);
}

- (void)testMutlipleParamMethod {
    Tweak(NSTestClass, multiple:param:method:, YES);
    MKMethod *same = [MKMethod methodForSelector:@selector(multiple:param:method:) class:[NSTestClass class] instance:YES];
    XCTAssertEqualObjects(hook.method.typeEncoding, same.typeEncoding);
}

- (void)testInvalidHook {
    XCTAssertThrows(Hook(NSTestClass, unimplemented, YES));
}

- (void)testUnhookables {
    Tweak(NSTestClass, returnsAndTakesAnonymousStructs:, YES);
    XCTAssertFalse(hook.canOverrideReturnValue);
    XCTAssertFalse(hook.canOverrideAllArgumentValues);
}

- (void)testDoNothingFormat {
    // Object
    Tweak(NSTestClass, name, YES);
    hook.chirpString = @"";

    
    // Enable and test
    [tweak tryEnable:^(NSError *error) {
        XCTFail(@"Should succeed: %@", error);
    }];
    XCTAssertTrue(tweak.enabled);
    XCTAssertNil(self.testInstance.name);
    
    // Disable and test
    [tweak disable];
    XCTAssertFalse(tweak.enabled);
    XCTAssertNotNil(self.testInstance.name);
}

- (void)testHookReturnValue_primitive {
    Tweak(NSTestClass, length, YES);
    hook.hookedReturnValue = [TBValue value:@1337 type:TBValueTypeInteger];

    // Enable and test
    [tweak tryEnable:^(NSError *error) {
        XCTFail(@"Should succeed: %@", error);
    }];
    XCTAssertTrue(tweak.enabled);
    XCTAssertEqual(self.testInstance.length, 1337);
    
    // Disable and test
    [tweak disable];
    XCTAssertFalse(tweak.enabled);
    XCTAssertEqual(self.testInstance.length, 3);
}

- (void)testHookReturnValue_object {
    Tweak(NSString, lastPathComponent, YES);
    XCTAssertNotNil(tweak);
    hook.hookedReturnValue = [TBValue value:@"foo" type:TBValueTypeString];
    
    // Enable and test
    [tweak tryEnable:^(NSError *error) {
        XCTFail(@"Should succeed: %@", error);
    }];
    XCTAssertTrue(tweak.enabled);
    
    XCTAssertEqualObjects(@"2345678yoihugyhcg".lastPathComponent, @"foo");
    XCTAssertEqualObjects(@"Users/me/Documents/file.plist".lastPathComponent, @"foo");
    
    // Disable and test
    [tweak disable];
    XCTAssertFalse(tweak.enabled);
    XCTAssertEqualObjects(@"Users/me/Documents/file.plist".lastPathComponent, @"file.plist");
}

- (void)testHookReturnValue_structs {
    CGRect r = CGRectMake(1, 2, 3, 4);
    CGRect orig = self.testInstance.frame;
    XCTAssertFalse(CGRectEqualToRect(r, orig));
    
    Tweak(NSTestClass, frame, YES);
    XCTAssertTrue(hook.canOverrideReturnValue);
    hook.hookedReturnValue = [TBValue value:[NSValue valueWithCGRect:r] structType:TBStructTypeRect];
    
    // Enable and test
    [tweak tryEnable:^(NSError *error) {
        XCTFail(@"Should succeed: %@", error);
    }];
    XCTAssertTrue(tweak.enabled);
    XCTAssertTrue(CGRectEqualToRect(self.testInstance.frame, r));
    
    // Disable and test
    [tweak disable];
    XCTAssertFalse(tweak.enabled);
    XCTAssertTrue(CGRectEqualToRect(self.testInstance.frame, orig));
}

- (void)testHookFirstArgument {
    id val = [NSDate date];
    id param = @"foo";
    Tweak(NSTestClass, multiple:param:method:, YES);
    hook.hookedArguments = @[[TBValue orig], [TBValue orig],
                             [TBValue value:val type:TBValueTypeDate], [TBValue orig], [TBValue orig]];
    
    // Enable and test
    [tweak tryEnable:^(NSError *error) {
        XCTFail(@"Should succeed: %@", error);
    }];
    XCTAssertTrue(tweak.enabled);
    id foo = [self.testInstance multiple:param param:YES method:'a'];
    XCTAssertEqualObjects(val, foo);
    
    // Disable and test
    [tweak disable];
    XCTAssertFalse(tweak.enabled);
    XCTAssertEqualObjects(param, [self.testInstance multiple:param param:YES method:'a']);
}

- (void)testHookSecondArgument {
    Tweak(NSTestClass, multiple:param:method:, YES);
    hook.hookedArguments = @[[TBValue orig], [TBValue orig],
                             [TBValue orig], [TBValue value:@NO type:TBValueTypeInteger], [TBValue orig]];
    
    // Enable and test
    [tweak tryEnable:^(NSError *error) {
        XCTFail(@"Should succeed: %@", error);
    }];
    XCTAssertTrue(tweak.enabled);
    XCTAssertNil([self.testInstance multiple:@"foo" param:YES method:'a']);
    
    // Disable and test
    [tweak disable];
    XCTAssertFalse(tweak.enabled);
    XCTAssertNotNil([self.testInstance multiple:@"foo" param:YES method:'a']);
}

- (void)testHookAllArguments {
    Tweak(NSTestClass, multiple:param:method:, YES);
    hook.hookedArguments = @[[TBValue orig], [TBValue orig], [TBValue null], [TBValue null], [TBValue null]];
    
    // Enable and test
    [tweak tryEnable:^(NSError *error) {
        XCTFail(@"Should succeed: %@", error);
    }];
    XCTAssertTrue(tweak.enabled);
    XCTAssertNil([self.testInstance multiple:@"foo" param:YES method:'a']);
    
    // Disable and test
    [tweak disable];
    XCTAssertFalse(tweak.enabled);
    XCTAssertNotNil([self.testInstance multiple:@"foo" param:YES method:'a']);
}

- (void)testHookClassMethod {
    Tweak(NSTestClass, classLength, NO);
    hook.hookedReturnValue = [TBValue value:@8 type:TBValueTypeInteger];
    
    // Enable and test
    [tweak tryEnable:^(NSError *error) {
        XCTFail(@"Should succeed: %@", error);
    }];
    XCTAssertTrue(tweak.enabled);
    XCTAssertEqual([NSTestClass classLength], 8);
    
    // Disable and test
    [tweak disable];
    XCTAssertFalse(tweak.enabled);
    XCTAssertEqual([NSTestClass classLength], 10);
}

- (void)testChirpString {
    // TODO
}

- (void)testNSCoding {
    
}

@end
