//
//  UIViewController+Dismissal.m
//  TBTweakViewController
//
//  Created by Tanner on 8/22/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "UIViewController+Dismissal.h"


@implementation UIViewController (Dismissal)

- (void)dismissAnimated {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
