//
//  NSScanner+ChirpParser.m
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "NSScanner+ChirpParser.h"
#import "NSError+Message.h"
#import <objc/runtime.h>
#import <UIKit/UIGeometry.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreMedia/CoreMedia.h>


#define BlockReturnEmpty(type) imp_implementationWithBlock(^(id reciever) { \
return (type)0; \
})
#define BlockStructReturnEmpty(type) imp_implementationWithBlock(^(id reciever) { \
return (type){0}; \
})

IMP imp_emptyIMPForReturnTypeAndSize(MKMethod *method) {
    switch (method.returnType) {
        case MKTypeEncodingUnknown:
        case MKTypeEncodingVoid: {
            return imp_implementationWithBlock(^(id reciever) { ; });
        }
        case MKTypeEncodingChar: {
            return BlockReturnEmpty(char);
        }
        case MKTypeEncodingInt: {
            return BlockReturnEmpty(int);
        }
        case MKTypeEncodingShort: {
            return BlockReturnEmpty(char);
        }
        case MKTypeEncodingLong: {
            return BlockReturnEmpty(long);
        }
        case MKTypeEncodingLongLong: {
            return BlockReturnEmpty(long long);
        }
        case MKTypeEncodingUnsignedChar: {
            return BlockReturnEmpty(unsigned char);
        }
        case MKTypeEncodingUnsignedInt: {
            return BlockReturnEmpty(unsigned int);
        }
        case MKTypeEncodingUnsignedShort: {
            return BlockReturnEmpty(unsigned short);
        }
        case MKTypeEncodingUnsignedLong: {
            return BlockReturnEmpty(unsigned long);
        }
        case MKTypeEncodingUnsignedLongLong: {
            return BlockReturnEmpty(unsigned long long);
        }
        case MKTypeEncodingFloat: {
            return BlockReturnEmpty(float);
        }
        case MKTypeEncodingDouble: {
            return BlockReturnEmpty(double);
        }
        case MKTypeEncodingCBool: {
            return BlockReturnEmpty(bool);
        }
        case MKTypeEncodingCString:
        case MKTypeEncodingSelector:
        case MKTypeEncodingPointer: {
            return BlockReturnEmpty(void *);
        }
        case MKTypeEncodingStruct:
        case MKTypeEncodingUnion:
        case MKTypeEncodingBitField:
        case MKTypeEncodingArray: {
            // Get return size of method
            NSUInteger returnSize;
            NSGetSizeAndAlignment(method.signature.methodReturnType, &returnSize, NULL);
            
            
            if (returnSize == sizeof(NSRange)) {
                return BlockStructReturnEmpty(NSRange);
            }
            
            // Skip CGVector, CGSize
            if (returnSize == sizeof(CGPoint)) {
                return BlockStructReturnEmpty(CGPoint);
            }
            if (returnSize == sizeof(CGRect)) {
                return BlockStructReturnEmpty(CGRect);
            }
            if (returnSize == sizeof(CGAffineTransform)) {
                return BlockStructReturnEmpty(CGAffineTransform);
            }
            // Skip UIOffset
            if (returnSize == sizeof(UIEdgeInsets)) {
                return BlockStructReturnEmpty(UIEdgeInsets);
            }
            
            if (returnSize == sizeof(CATransform3D)) {
                return BlockStructReturnEmpty(CATransform3D);
            }
            
            [NSException raise:NSInternalInconsistencyException format:@"Unsupported return type hook"];
        }
        case MKTypeEncodingObjcObject:
        case MKTypeEncodingObjcClass: {
            return BlockReturnEmpty(id);
        }
    }
}

@implementation NSScanner (ChirpParser)

- (BOOL)scanChirp:(IMP *)imp method:(MKMethod *)method error:(NSError **)error {
    NSParameterAssert(imp); NSParameterAssert(method);
    
    // Return empty value
    if (!self.string.length) {
        *imp = imp_emptyIMPForReturnTypeAndSize(method);
        return YES;
    }
    
    // TODO
    
    if (error) {
        *error = [NSError error:@"Not done yet"];
    }
    
    return NO;
}

@end
