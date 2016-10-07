//
//  NSTestClass.h
//  TBTweakViewController
//
//  Created by Tanner on 8/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSTestClass : NSObject

@property (nonatomic          ) NSInteger length;
@property (nonatomic          ) char      character;
@property (nonatomic, readonly) BOOL      conditon;

@property (nonatomic) NSString *name;

@property (nonatomic) CGRect frame;
@property (nonatomic) CGPoint center;

- (void)doNothingMethod;
- (id)multiple:(id)arg1 param:(BOOL)arg2 method:(char)arg3;

- (struct { int x, y, z; })returnsAndTakesAnonymousStructs:(struct { short a, b; })arg1;

- (void)unimplemented;

/// @return 10
+ (NSInteger)classLength;

@end
