//
//  TBMethodHook+Limitations.m
//  TBTweakViewController
//
//  Created by Tanner on 3/8/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBMethodHook+Limitations.h"

#import <UIKit/UIGeometry.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>


@implementation TBMethodHook (Limitations)

+ (BOOL)canHookValueOfType:(const char *)fullTypeEncoding {
    MKTypeEncoding type = fullTypeEncoding[0];

    if (type == MKTypeEncodingVoid ||
        type == MKTypeEncodingUnknown) {
        return NO;
    }

    // Can only hook certain structure sizes
    if (type == MKTypeEncodingStruct ||
        type == MKTypeEncodingUnion ||
        type == MKTypeEncodingBitField) {

        NSUInteger returnSize;
        NSGetSizeAndAlignment(fullTypeEncoding, &returnSize, NULL);
        if (returnSize != sizeof(NSRange) &&
            returnSize != sizeof(CGPoint) &&
            returnSize != sizeof(CGRect) &&
            returnSize != sizeof(CGAffineTransform) &&
            returnSize != sizeof(UIEdgeInsets) &&
            returnSize != sizeof(CATransform3D)) {
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL)canHookReturnTypeOf:(MKMethod *)method {
    return [self canHookValueOfType:method.signature.methodReturnType];
}

+ (BOOL)canHookAllArgumentTypesOf:(MKMethod *)method {
    for (NSInteger i = 2; i < method.numberOfArguments; i++) {
        if (![self canHookValueOfType:[method.signature getArgumentTypeAtIndex:i]]) {
            return NO;
        }
    }

    return method.numberOfArguments > 2;
}

@end
