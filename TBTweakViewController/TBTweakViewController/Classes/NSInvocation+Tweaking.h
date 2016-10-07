//
//  NSInvocation+Tweaking.h
//  TBTweakViewController
//
//  Created by Tanner on 8/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TBValue;


@interface NSInvocation (Tweaking)

- (void)overrideArguments:(NSArray<TBValue*> *)args;

@end
