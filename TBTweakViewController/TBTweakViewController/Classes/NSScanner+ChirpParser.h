//
//  NSScanner+ChirpParser.h
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MirrorKit/MKMethod.h"


@interface NSScanner (ChirpParser)

- (BOOL)scanChirp:(IMP *)imp method:(MKMethod *)method error:(NSError **)error;

@end

#define VAArgsInit(start) va_list __args; va_start(__args, start); va_arg(__args, SEL)
#define VAArgsEnd() va_end(__args)

#define _TBSetVAArgumentWithType(type, idx) ({ type tmp = va_arg(__args, type); [invocation setArgument:&tmp atIndex: idx]; })
#define TBSetInvocationArgumentAtIndexFromVA_Args(invocation, idx) \
MKTypeEncoding type = [invocation.methodSignature getArgumentTypeAtIndex: idx][0]; \
switch (type) { \
    case MKTypeEncodingUnknown: \
    case MKTypeEncodingVoid: { \
        break; \
    } \
    case MKTypeEncodingChar: { \
        _TBSetVAArgumentWithType(char, idx); \
        break; \
    } \
    case MKTypeEncodingInt: { \
        _TBSetVAArgumentWithType(int, idx); \
        break; \
    } \
    case MKTypeEncodingShort: { \
        _TBSetVAArgumentWithType(short, idx); \
        break; \
    } \
    case MKTypeEncodingLong: { \
        _TBSetVAArgumentWithType(long, idx); \
        break; \
    } \
    case MKTypeEncodingLongLong: { \
        _TBSetVAArgumentWithType(long long, idx); \
        break; \
    } \
    case MKTypeEncodingUnsignedChar: { \
        _TBSetVAArgumentWithType(unsigned char, idx); \
        break; \
    } \
    case MKTypeEncodingUnsignedInt: { \
        _TBSetVAArgumentWithType(unsigned int, idx); \
        break; \
    } \
    case MKTypeEncodingUnsignedShort: { \
        _TBSetVAArgumentWithType(unsigned short, idx); \
        break; \
    } \
    case MKTypeEncodingUnsignedLong: { \
        _TBSetVAArgumentWithType(unsigned long, idx); \
        break; \
    } \
    case MKTypeEncodingUnsignedLongLong: { \
        _TBSetVAArgumentWithType(unsigned long long, idx); \
        break; \
    } \
    case MKTypeEncodingFloat: { \
        _TBSetVAArgumentWithType(float, idx); \
        break; \
    } \
    case MKTypeEncodingDouble: { \
        _TBSetVAArgumentWithType(double, idx); \
        break; \
    } \
    case MKTypeEncodingCBool: { \
        _TBSetVAArgumentWithType(bool, idx); \
        break; \
    } \
    case MKTypeEncodingCString: \
    case MKTypeEncodingSelector: \
    case MKTypeEncodingPointer: { \
        _TBSetVAArgumentWithType(void *, idx); \
        break; \
    } \
    case MKTypeEncodingStruct: \
    case MKTypeEncodingUnion: \
    case MKTypeEncodingBitField: \
    case MKTypeEncodingArray: { \
        size_t returnSize; \
        NSGetSizeAndAlignment([invocation.methodSignature getArgumentTypeAtIndex: idx], &returnSize, NULL); \
        if (returnSize == sizeof(NSRange)) { \
            _TBSetVAArgumentWithType(NSRange, idx); \
        } \
        else if (returnSize == sizeof(CGPoint)) { \
            _TBSetVAArgumentWithType(CGPoint, idx); \
        } \
        else if (returnSize == sizeof(CGRect)) { \
            _TBSetVAArgumentWithType(CGRect, idx); \
        } \
        else if (returnSize == sizeof(CGAffineTransform)) { \
            _TBSetVAArgumentWithType(CGAffineTransform, idx); \
        } \
        else if (returnSize == sizeof(UIEdgeInsets)) { \
            _TBSetVAArgumentWithType(UIEdgeInsets, idx); \
        } \
        else if (returnSize == sizeof(CATransform3D)) { \
            _TBSetVAArgumentWithType(CATransform3D, idx); \
        } \
        else { \
            [NSException raise:NSInternalInconsistencyException format:@"Unsupported argument type hook"]; \
        } \
        break; \
    } \
    case MKTypeEncodingObjcObject: \
    case MKTypeEncodingObjcClass: { \
        _TBSetVAArgumentWithType(id, idx); \
        break; \
    } \
}
