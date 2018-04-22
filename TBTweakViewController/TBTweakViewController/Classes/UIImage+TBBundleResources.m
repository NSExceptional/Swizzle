//
//  UIImage+TBBundleResources.m
//  TBTweakViewController
//
//  Created by Tanner on 3/9/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "UIImage+TBBundleResources.h"


static NSBundle * TBBundleForImages() {
#if 1
    return [NSBundle bundleWithPath:@"/Library/Application Support/Swizzle.bundle"];
#else
    return [NSBundle mainBundle];
#endif
}

UIImage * TBImageNamed(NSString *name) {
    return [UIImage imageNamed:name inBundle:TBBundleForImages() compatibleWithTraitCollection:nil];
}


@implementation UIImage (TBBundleResources)

+ (UIImage *)appsTabImage {
    return TBImageNamed(@"tab_app");
}

+ (UIImage *)systemTabImage {
    return TBImageNamed(@"tab_system");
}

+ (UIImage *)iconForHookType:(TBHookType)type {
    NSString *name;
    switch (type) {
        case TBHookTypeUnspecified:
            break;
        case TBHookTypeChirpCode:
            name = @"chirp_code";
            break;
        case TBHookTypeReturnValue:
            name = @"override_return_icon";
            break;
        case TBHookTypeArguments:
            name = @"override_params_icon";
            break;
    }

    return TBImageNamed(name);
}

@end
