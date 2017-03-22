//
//  UIBarButtonItem+Convenience.m
//  TBTweakViewController
//
//  Created by Tanner on 3/9/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "UIBarButtonItem+Convenience.h"

@implementation UIBarButtonItem (Convenience)

+ (instancetype)item:(UIBBItem)item {
    return [[self alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItem)item target:nil action:nil];
}
+ (instancetype)item:(UIBBItem)item target:(id)target action:(SEL)action {
    return [[self alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItem)item target:target action:action];
}

@end
