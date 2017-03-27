//
//  UIGestureRecognizer+Blocks.h
//  TBTweakViewController
//
//  Created by Tanner on 3/26/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^GestureBlock)(UIGestureRecognizer *gesture);

@interface UIGestureRecognizer (Blocks)

+ (instancetype)action:(GestureBlock)action;

@property (nonatomic) GestureBlock action;

@end
