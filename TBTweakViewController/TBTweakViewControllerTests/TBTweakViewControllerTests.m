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

#define Tweak(target, sel) [TBTweak tweakWithTarget:[target class] instanceMethod:@selector(sel)]
#define ClassTweak(target, sel) [TBTweak tweakWithTarget:[target class] method:@selector(sel)]

@interface TBTweakViewControllerTests : XCTestCase
@property (nonatomic) NSTestClass *testInstance;
@end

@implementation TBTweakViewControllerTests

- (void)setUp {
    self.testInstance = [NSTestClass new];
    self.testInstance.name      = @"foo";
    self.testInstance.length    = 3;
    self.testInstance.frame     = CGRectMake(1, 1, 1, 1);
    self.testInstance.center    = CGPointMake(2, 2);
    self.testInstance.character = 'a';
}

- (void)testBasics {
    // Tweak
    TBTweak *tweak = Tweak(NSTestClass, length);
    XCTAssertFalse(tweak.enabled);
    
    // Hook
    XCTAssertTrue(tweak.hook.canOverrideReturnValue);
    XCTAssertFalse(tweak.hook.canOverrideAllArgumentValues);
    XCTAssertEqual(tweak.hook.method.signature.numberOfArguments, 2);
    XCTAssertEqualObjects(tweak.hook.target, @"NSTestClass");
    XCTAssertFalse(tweak.hook.isClassMethod);
    
    // Method
    MKMethod *same = [MKMethod methodForSelector:@selector(length) class:[NSTestClass class] instance:YES];
    XCTAssertEqualObjects(tweak.hook.method.typeEncoding, same.typeEncoding);
    
    tweak = Tweak(NSTestClass, multiple:param:method:);
    same = [MKMethod methodForSelector:@selector(multiple:param:method:) class:[NSTestClass class] instance:YES];
    XCTAssertEqualObjects(tweak.hook.method.typeEncoding, same.typeEncoding);
    
    // Invalid tweaks
    tweak = Tweak(NSTestClass, unimplemented);
    XCTAssertNil(tweak);
    
    // Unhookables
    tweak = Tweak(NSTestClass, returnsAndTakesAnonymousStructs:);
    XCTAssertFalse(tweak.hook.canOverrideReturnValue);
    XCTAssertFalse(tweak.hook.canOverrideAllArgumentValues);
}

- (void)testDoNothingFormat {
    // Object
    TBTweak *tweak = Tweak(NSTestClass, name);
    tweak.hook.chirpString = @"";
    
    // Enable and test
    [tweak tryEnable:^(NSError * _Nonnull error) {
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
    TBTweak *tweak = Tweak(NSTestClass, length);
    tweak.hook.hookedReturnValue = [TBValue value:@1337];
    
    // Enable and test
    [tweak tryEnable:^(NSError * _Nonnull error) {
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
    TBTweak *tweak = Tweak(NSString, lastPathComponent);
    XCTAssertNotNil(tweak);
    tweak.hook.hookedReturnValue = [TBValue value:@"foo"];
    
    // Enable and test
    [tweak tryEnable:^(NSError * _Nonnull error) {
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
    
    TBTweak *tweak = Tweak(NSTestClass, frame);
    XCTAssertTrue(tweak.hook.canOverrideReturnValue);
    tweak.hook.hookedReturnValue = [TBValue value:[NSValue valueWithCGRect:r]];
    
    // Enable and test
    [tweak tryEnable:^(NSError * _Nonnull error) {
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
    TBTweak *tweak = Tweak(NSTestClass, multiple:param:method:);
    tweak.hook.hookedArguments = @[[TBValue value:val], [TBValue orig], [TBValue orig]];
    
    // Enable and test
    [tweak tryEnable:^(NSError * _Nonnull error) {
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
    TBTweak *tweak = Tweak(NSTestClass, multiple:param:method:);
    tweak.hook.hookedArguments = @[[TBValue orig], [TBValue value:@NO], [TBValue orig]];
    
    // Enable and test
    [tweak tryEnable:^(NSError * _Nonnull error) {
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
    TBTweak *tweak = Tweak(NSTestClass, multiple:param:method:);
    tweak.hook.hookedArguments = @[[TBValue null], [TBValue null], [TBValue null]];
    
    // Enable and test
    [tweak tryEnable:^(NSError * _Nonnull error) {
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
    TBTweak *tweak = ClassTweak(NSTestClass, classLength);
    tweak.hook.hookedReturnValue = [TBValue value:@8];
    
    // Enable and test
    [tweak tryEnable:^(NSError * _Nonnull error) {
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
