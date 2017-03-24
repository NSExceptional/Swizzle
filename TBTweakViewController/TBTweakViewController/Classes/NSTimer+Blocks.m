//
//  NSTimer+Blocks.m
//  TBTweakViewController
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "NSTimer+Blocks.h"


@interface Block : NSObject
- (void)invoke;
@end

@implementation NSTimer (Blocks)

+ (instancetype)fireSecondsFromNow:(NSTimeInterval)delay block:(VoidBlock)block {
    if (NSClassFromString(@"UIPreviewInteraction")) {
        return [self scheduledTimerWithTimeInterval:delay repeats:NO block:block];
    } else {
        return [self scheduledTimerWithTimeInterval:delay target:block selector:@selector(invoke) userInfo:nil repeats:NO];
    }
}

@end
