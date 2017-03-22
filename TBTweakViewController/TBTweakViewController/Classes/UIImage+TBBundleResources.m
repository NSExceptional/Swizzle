//
//  UIImage+TBBundleResources.m
//  TBTweakViewController
//
//  Created by Tanner on 3/9/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "UIImage+TBBundleResources.h"


UIImage * TBImageNamed(NSString *name) {
#if THEOS
    NSString *imagePath = [[self bundleForImages] pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:imagePath];
#else
    return [UIImage imageNamed:name];
#endif
}


@implementation UIImage (TBBundleResources)

+ (NSBundle *)bundleForImages {
    return [NSBundle bundleForClass:[self class]];
}

+ (UIImage *)appsTabImage {
    return TBImageNamed(@"tab_app");
}

+ (UIImage *)systemTabImage {
    return TBImageNamed(@"tab_system");
}

+ (UIImage *)iconForTweakType:(TBTweakType)type {
    NSString *name;
    switch (type) {
        case TBTweakTypeUnspecified:
            break;
        case TBTweakTypeChirpCode:
            name = @"chirp_code";
            break;
        case TBTweakTypeHookReturnValue:
            name = @"override_return_icon";
            break;
        case TBTweakTypeHookArguments:
            name = @"override_params_icon";
            break;
    }

    return TBImageNamed(name);
}

@end
