//
//  UIViewController+Convenience.h
//  TBTweakViewController
//
//  Created by Tanner on 3/9/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Convenience)

+ (instancetype)title:(NSString *)title;
+ (instancetype)title:(NSString *)title configuration:(void(^)(UINavigationItem *item, id vc))config;

@property (nonatomic, readonly) UINavigationController *inNavController;

- (void)dismissAnimated;

@end
