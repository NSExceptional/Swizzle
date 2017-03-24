//
//  NSTimer+Blocks.h
//  TBTweakViewController
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^VoidBlock)();
@interface NSTimer (Blocks)

+ (instancetype)fireSecondsFromNow:(NSTimeInterval)delay block:(VoidBlock)block;

@end
