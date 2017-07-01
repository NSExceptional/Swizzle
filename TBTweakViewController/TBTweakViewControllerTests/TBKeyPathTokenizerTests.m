//
//  TBKeyPathTokenizerTests.m
//  TBTweakViewController
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TBKeyPathTokenizer.h"


@interface TBKeyPathTokenizerTests : XCTestCase {
    NSNull *null;
    NSNumber *FAILS, *WORKS;
}
@property (nonatomic, readonly) NSDictionary *testInputs;
@end

@implementation TBKeyPathTokenizerTests

- (void)setUp {
    null = [NSNull null];

    // Map of { input: [ fails, [strings], option, instance ]
    FAILS = @YES;
    WORKS = @NO;
    NSNumber *none  = @(TBWildcardOptionsNone);
    NSNumber *any   = @(TBWildcardOptionsAny);
    NSNumber *pre   = @(TBWildcardOptionsPrefix);
    NSNumber *post  = @(TBWildcardOptionsSuffix);
    NSNumber *both  = @(TBWildcardOptionsPrefix | TBWildcardOptionsSuffix);
    NSNumber *instance    = @YES;
    NSNumber *classMethod = @NO;
    NSArray  *EXPECTS_FAILURE = @[FAILS, null, null, null];

    _testInputs = @{
                    @"Bundle.class.-foo": @[WORKS,
                                            @[@"Bundle", @"class", @"foo"],
                                            @[none, none, post],
                                            instance],
                    @"Bundle.class.+foo": @[WORKS,
                                            @[@"Bundle", @"class", @"foo"],
                                            @[none, none, post],
                                            classMethod],
                    @"Bundle.class.": @[WORKS,
                                        @[@"Bundle", @"class", null],
                                        @[none, none, any],
                                        null],
                    @"Bundle.class": @[WORKS,
                                       @[@"Bundle", @"class"],
                                       @[none, post],
                                       null],
                    @"Bundle.": @[WORKS,
                                  @[@"Bundle", null],
                                  @[none, any],
                                  null],
                    @"Bundle": @[WORKS,
                                 @[@"Bundle"],
                                 @[post],
                                 null],
                    @"$Bundle.class.-foo": @[WORKS,
                                             @[@"$Bundle", @"class", @"foo"],
                                             @[none, none, post],
                                             instance],
                    @"_Bundle.$class.-$foo": @[WORKS,
                                               @[@"_Bundle", @"$class", @"$foo"],
                                               @[none, none, post],
                                               instance],
                    @"Bu\\.ndle.class.-foo": @[WORKS,
                                               @[@"Bu.ndle", @"class", @"foo"],
                                               @[none, none, post],
                                               instance],
                    @"Bu\\.ndle.cl\\.ass.-foo": @[WORKS,
                                                  @[@"Bu.ndle", @"cl.ass", @"foo"],
                                                  @[none, none, post],
                                                  instance],
                    @"Bu\\.ndle.cl\\.ass.-f\\.oo": @[WORKS,
                                                     @[@"Bu.ndle", @"cl.ass", @"f.oo"],
                                                     @[none, none, post],
                                                     instance],
                    @"Bu\\.ndle.cl\\.ass.-f\\.oo": @[WORKS,
                                                     @[@"Bu.ndle", @"cl.ass", @"f.oo"],
                                                     @[none, none, post],
                                                     instance],
                    @".Bundle": EXPECTS_FAILURE,
                    @"Bundle..class": EXPECTS_FAILURE,
                    @"Bundle.class..": EXPECTS_FAILURE,
                    @"Bundle.class..-foo": EXPECTS_FAILURE,
                    @"*.": @[WORKS,
                             @[null, null],
                             @[any, any],
                             null],
                    @"*.class": @[WORKS,
                                  @[null, @"class"],
                                  @[any, post],
                                  null],
                    @"*.class.-foo": @[WORKS,
                                      @[null, @"class", @"foo"],
                                      @[any, none, post],
                                      instance],
                    @"*.*": @[WORKS,
                              @[null, null],
                              @[any, any],
                              null],
                    @"*.*.-foo": @[WORKS,
                                  @[null, null, @"foo"],
                                  @[any, any, post],
                                  instance],
                    @"*.*.*": @[WORKS,
                                @[null, null, null],
                                @[any, any, any],
                                null],
                    @"1Bundle": @[WORKS,
                                  @[@"1Bundle"],
                                  @[post],
                                  null],
                    @"Bundle.-1class": EXPECTS_FAILURE,
                    @"Bundle.class.-1foo": EXPECTS_FAILURE,

                    @"*Bundle": @[WORKS,
                                  @[@"Bundle"],
                                  @[both],
                                  null],
                    @"*Bundle*": @[WORKS,
                                   @[@"Bundle"],
                                   @[both],
                                   null],
                    @"Bundle*": @[WORKS,
                                  @[@"Bundle"],
                                  @[post],
                                  null],

                    @"*Bundle.class": @[WORKS,
                                  @[@"Bundle", @"class"],
                                  @[pre, post],
                                  null],
                    @"Bundle*.*class": @[WORKS,
                                  @[@"Bundle", @"class"],
                                  @[post, both],
                                  null],
                    @"*Bundle*.*class*": @[WORKS,
                                   @[@"Bundle", @"class"],
                                   @[both, both],
                                   null],

                    @"*Bundle.class.*foo": @[WORKS,
                                             @[@"Bundle", @"class", @"foo"],
                                             @[pre, none, both],
                                             null],
                    @"*Bundle.class.-foo*": @[WORKS,
                                              @[@"Bundle", @"class", @"foo"],
                                              @[pre, none, post],
                                              instance],
                    @"Bundle*.*class.-foo": @[WORKS,
                                              @[@"Bundle", @"class", @"foo"],
                                              @[post, pre, post],
                                              instance],
                    @"*Bundle*.*class*.*": @[WORKS,
                                             @[@"Bundle", @"class", null],
                                             @[both, both, any],
                                             null],
                    @"Bundle.class.*-foo": EXPECTS_FAILURE,
                    @"Bundle.class.*+foo": EXPECTS_FAILURE,
                    @"**Bundle.class.foo": EXPECTS_FAILURE,
                    @"*Bundle**.class.-foo": EXPECTS_FAILURE,
                    @"*Bun*dle.class.-foo": EXPECTS_FAILURE,
                    @"Bu*ndle.class.-foo": EXPECTS_FAILURE,
                    @"Bundle.cl*ass.-foo": EXPECTS_FAILURE,
                    @"Bundle.class.-foo": EXPECTS_FAILURE,
                    @"Bundle.class**.-foo": EXPECTS_FAILURE,
                    @"Bundle.class.-*foo": EXPECTS_FAILURE,
                    @"Bundle.class.*-foo": EXPECTS_FAILURE,
                    @"Bundle.class.**foo": EXPECTS_FAILURE,
                    @"Bundle.class.**": EXPECTS_FAILURE,
                    @"**": EXPECTS_FAILURE,
                    @"Bundle.**": EXPECTS_FAILURE,
                    @"Bundle.-": EXPECTS_FAILURE,
                    @"Bundle.-foo=": EXPECTS_FAILURE,

                    @"B-undle": @[WORKS,
                                  @[@"B-undle"],
                                  @[post],
                                  null],
                    @"Bundle++": @[WORKS,
                                   @[@"Bundle++"],
                                   @[post],
                                   null],
                    @"-Bun?dle++": @[WORKS,
                                   @[@"-Bun?dle++"],
                                   @[post],
                                   null],

                    @"Bundle.class.-": @[WORKS,
                                         @[@"Bundle", @"class", @""],
                                         @[none, none, post],
                                         instance],
                    @"Bundle.class.+": @[WORKS,
                                         @[@"Bundle", @"class", @""],
                                         @[none, none, post],
                                         classMethod],

                    @"Bundle.class.-foo:": @[WORKS,
                                             @[@"Bundle", @"class", @"foo:"],
                                             @[none, none, post],
                                             instance],
                    @"Bundle.class.-foo:bar:": @[WORKS,
                                                 @[@"Bundle", @"class", @"foo:bar:"],
                                                 @[none, none, post],
                                                 instance],
                    @"Bundle.class.-foo:bar:baz:": @[WORKS,
                                                     @[@"Bundle", @"class", @"foo:bar:baz:"],
                                                     @[none, none, post],
                                                     instance],
                    @"Bundle.class.-foo:::": @[WORKS,
                                               @[@"Bundle", @"class", @"foo:::"],
                                               @[none, none, post],
                                               instance],
                    @"Bundle:.class.-foo": EXPECTS_FAILURE,
                    @":Bundle.class.-foo": EXPECTS_FAILURE,
                    @"Bundle.:class.-foo": EXPECTS_FAILURE,
                    @"Bundle.cla:ss.-foo": EXPECTS_FAILURE,
                    @"Bundle.class.-:foo": EXPECTS_FAILURE,
                    @"Bundle.class.-foo.": EXPECTS_FAILURE,
                    @"Bundle.class.-foo:bar": @[WORKS,
                                                @[@"Bundle", @"class", @"foo:bar"],
                                                @[none, none, post],
                                                instance],
                    };
}

- (void)check:(TBToken *)token strs:(NSArray<NSString*> *)strings opts:(NSArray<NSNumber*> *)options idx:(int)i {
    #define ValueOrNil(thing) ((id)thing == (id)null ? nil : thing)
    if (token) {
        id expected = ValueOrNil(strings[i]);
        XCTAssertEqualObjects(token.string, expected);

        TBWildcardOptions opts = options[i].integerValue;
        XCTAssertEqual(token.options, opts);
    } else {
        XCTAssertEqual(strings.count, i);
    }
}

- (void)test {
    [self.testInputs enumerateKeysAndObjectsUsingBlock:^(NSString *keyPath, NSArray *expected, BOOL *stop) {
        if ([expected[0] isEqual:FAILS]) {
            @try {
                [TBKeyPathTokenizer tokenizeString:keyPath];
                NSLog(@"");
            } @catch (id exception) {

            }
        } else {
            @try {
                TBKeyPath *kp = [TBKeyPathTokenizer tokenizeString:keyPath];
                NSArray<NSString*> *strings = expected[1];
                NSArray<NSNumber*> *options = expected[2];
                NSNumber *instance          = ValueOrNil(expected[3]);
                assert(strings.count == options.count);

                // TODO works for nil?
                XCTAssertEqualObjects(kp.instanceMethods, instance);

                [self check:kp.bundleKey strs:strings opts:options idx:0];
                if (kp.bundleKey) {
                    [self check:kp.classKey strs:strings opts:options idx:1];
                    if (kp.classKey) {
                        [self check:kp.methodKey strs:strings opts:options idx:2];
                    }
                }
            } @catch (id e) {
                NSLog(@"%@", e);
            }
        }
    }];
}

@end
