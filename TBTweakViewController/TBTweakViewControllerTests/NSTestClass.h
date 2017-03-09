//
//  NSTestClass.h
//  TBTweakViewController
//
//  Created by Tanner on 8/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestStructs.h"

@interface NSTestClass : NSObject

@property (nonatomic          ) NSInteger length;
@property (nonatomic          ) char      character;
@property (nonatomic, readonly) BOOL      conditon;

@property (nonatomic) NSString *name;

@property (nonatomic) CGRect frame;
@property (nonatomic) CGPoint center;

- (void)doNothingMethod;
- (id)multiple:(id)arg1 param:(BOOL)arg2 method:(char)arg3;

- (Twenty)returnsAndTakesAnonymousStructs:(Six)arg1;

- (void)unimplemented;

/// @return 10
+ (NSInteger)classLength;

- (NSString *)manyArgMethod:(int)a x3:(int)b x4:(int)c x5:(int)d x6:(int)e x7:(int)f s:(int)s0 s:(int)s1;
- (NSString *)manyArgMethod:(int)a x3:(int)b x4:(int)c x5:(int)d x6:(int)e s:(CGPoint)s0 s:(int)s1 s:(int)s2;

- (CGRect)returnsRectArg:(CGRect)arg;
- (CGRect)returnsRectArg:(float)a f1:(float)b f2:(float)c f3:(float)d f4:(float)e f5:(float)e f6:(float)e f7:(float)e s:(CGRect)arg;

- (FloatMix)returnsFloatMixArg:(FloatMix)arg;
- (FloatLarge)returnsFloatLargeArg:(FloatLarge)arg;

@end
