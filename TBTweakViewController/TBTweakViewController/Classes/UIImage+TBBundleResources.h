//
//  UIImage+TBBundleResources.h
//  TBTweakViewController
//
//  Created by Tanner on 3/9/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTweak.h"


@interface UIImage (TBBundleResources)

+ (UIImage *)appsTabImage;
+ (UIImage *)systemTabImage;
+ (UIImage *)iconForHookType:(TBHookType)type;

@end
