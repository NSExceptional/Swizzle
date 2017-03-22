//
//  UIViewController+Convenience.m
//  TBTweakViewController
//
//  Created by Tanner on 3/9/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "UIViewController+Convenience.h"

@implementation UIViewController (Convenience)

+ (instancetype)title:(NSString *)title {
    UIViewController *me = [self new];
    me.title = title;

    return me;
}

+ (instancetype)title:(NSString *)title configuration:(void(^)(UINavigationItem *item, id vc))config {
    UIViewController *me = [self title:title];
    config(me.navigationItem, me);

    return me;
}

- (UINavigationController *)inNavController {
    return [[UINavigationController alloc] initWithRootViewController:self];
}

- (void)dismissAnimated {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
