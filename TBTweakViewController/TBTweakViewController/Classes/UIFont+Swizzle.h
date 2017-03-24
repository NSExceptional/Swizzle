//
//  UIFont+Swizzle.h
//  TBTweakViewController
//
//  Created by Tanner on 3/20/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Swizzle)

@property (nonatomic, readonly, class) UIFont *codeFont;
@property (nonatomic, readonly, class) UIFont *smallCodeFont;

@end
