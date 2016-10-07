//
//  NSInvocation+Tweaking.m
//  TBTweakViewController
//
//  Created by Tanner on 8/21/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "NSInvocation+Tweaking.h"
#import "TBValue.h"
#import "MirrorKit/MKMethod.h"
#import <UIKit/UIGeometry.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>


@implementation NSInvocation (Tweaking)

- (void)overrideArguments:(NSArray<TBValue *> *)args {
    NSInteger i = 2;
    
    for (TBValue *arg in args) {
        if (!arg.overriden) { i++; continue; }
        
        MKTypeEncoding type = [self.methodSignature getArgumentTypeAtIndex:i][0];
        switch (type) {
            case MKTypeEncodingUnknown:
            case MKTypeEncodingVoid: {
                break;
            }
            case MKTypeEncodingChar: {
                char tmp = [(id)arg.value charValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingInt: {
                int tmp = [(id)arg.value intValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingShort: {
                short tmp = [(id)arg.value shortValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingLong: {
                long tmp = [(id)arg.value longValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingLongLong: {
                long long tmp = [(id)arg.value longLongValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingUnsignedChar: {
                unsigned char tmp = [(id)arg.value unsignedCharValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingUnsignedInt: {
                unsigned int tmp = [(id)arg.value unsignedIntValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingUnsignedShort: {
                unsigned short tmp = [(id)arg.value unsignedShortValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingUnsignedLong: {
                unsigned long tmp = [(id)arg.value unsignedLongValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingUnsignedLongLong: {
                unsigned long long tmp = [(id)arg.value unsignedLongValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingFloat: {
                float tmp = [(id)arg.value floatValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingDouble: {
                double tmp = [(id)arg.value doubleValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingCBool: {
                bool tmp = [(id)arg.value boolValue];
                [self setArgument:&tmp atIndex:i];
            }
            case MKTypeEncodingCString:
            case MKTypeEncodingSelector:
            case MKTypeEncodingPointer: {
                void * tmp = [(id)arg.value pointerValue];
                [self setArgument:&tmp atIndex:i];
                break;
            }
            case MKTypeEncodingStruct:
            case MKTypeEncodingUnion:
            case MKTypeEncodingBitField:
            case MKTypeEncodingArray: {
                // Get return size of method
                NSUInteger returnSize;
                NSGetSizeAndAlignment([self.methodSignature getArgumentTypeAtIndex:i], &returnSize, NULL);
                
                
                if (returnSize == sizeof(NSRange)) {
                    NSRange tmp = [(id)arg.value rangeValue];
                    [self setArgument:&tmp atIndex:i];
                }
                
                // Skip CGVector, CGSize
                else if (returnSize == sizeof(CGPoint)) {
                    CGPoint tmp = [(id)arg.value CGPointValue];
                    [self setArgument:&tmp atIndex:i];
                }
                else if (returnSize == sizeof(CGRect)) {
                    CGRect tmp = [(id)arg.value CGRectValue];
                    [self setArgument:&tmp atIndex:i];
                }
                else if (returnSize == sizeof(CGAffineTransform)) {
                    CGAffineTransform tmp = [(id)arg.value CGAffineTransformValue];
                    [self setArgument:&tmp atIndex:i];
                }
                // Skip UIOffset
                else if (returnSize == sizeof(UIEdgeInsets)) {
                    UIEdgeInsets tmp = [(id)arg.value UIEdgeInsetsValue];
                    [self setArgument:&tmp atIndex:i];
                }
                
                else if (returnSize == sizeof(CATransform3D)) {
                    CATransform3D tmp = [(id)arg.value CATransform3DValue];
                    [self setArgument:&tmp atIndex:i];
                }
                
                else {
                    [NSException raise:NSInternalInconsistencyException format:@"Unsupported argument type hook"];
                }
                
                break;
            }
            case MKTypeEncodingObjcObject:
            case MKTypeEncodingObjcClass: {
                id val = arg.value;
                [self setArgument:&val atIndex:i];
                break;
            }
        }
        i++;
    }
}

@end
