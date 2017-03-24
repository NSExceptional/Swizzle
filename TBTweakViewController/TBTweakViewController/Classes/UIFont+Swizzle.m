//
//  UIFont+Swizzle.m
//  TBTweakViewController
//
//  Created by Tanner on 3/20/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "UIFont+Swizzle.h"

@implementation UIFont (Swizzle)

+ (UIFont *)codeFont {
    return [self fontWithName:@"Menlo-Regular" size:[self systemFontSize]];
}

+ (UIFont *)smallCodeFont {
    return [self fontWithName:@"Menlo-Regular" size:[self smallSystemFontSize]];
}

@end
