//
//  TBArgValueHookSectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 10/7/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBValueSectionController.h"


typedef NS_ENUM(NSUInteger, TBArgHookRow) {
    TBArgHookRowToggle,
    TBArgHookRowTypePicker,
    TBArgHookRowValueHolder
};

@protocol TBArgHookSectionDelegate <TBSectionControllerDelegate>
- (void)setArgumentHookValue:(TBValue *)value atIndex:(NSUInteger)idx;
@end

@interface TBArgValueHookSectionController : TBValueSectionController

+ (instancetype)delegate:(id<TBArgHookSectionDelegate>)delegate
               signature:(NSMethodSignature *)signature
           argumentIndex:(NSUInteger)idx;

@property (nonatomic, readonly) id<TBArgHookSectionDelegate> delegate;

@end
