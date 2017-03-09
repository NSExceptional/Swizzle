//
//  TBMethodHook+IMP.m
//  TBTweakViewController
//
//  Created by Tanner on 3/8/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBMethodHook+IMP.h"
#import "TBValueTypes.h"
#import "TBTrampoline.h"


#define BlockReturnSelector(sel) ({ \
    id value = self.hookedReturnValue.value; \
    imp_implementationWithBlock(^(id reciever) { \
        return [value sel]; \
    }); \
})

#define BlockReturn(foo) imp_implementationWithBlock(^(id reciever) { \
    return foo; \
})

@implementation TBMethodHook (IMP)

- (IMP)IMPForHookedReturnType {
    switch (self.method.returnType) {
        case MKTypeEncodingUnknown:
        case MKTypeEncodingVoid: {
            @throw NSInternalInconsistencyException;
            break;
        }
        case MKTypeEncodingChar: {
            return BlockReturnSelector(charValue);
            break;
        }
        case MKTypeEncodingInt: {
            return BlockReturnSelector(intValue);
            break;
        }
        case MKTypeEncodingShort: {
            return BlockReturnSelector(shortValue);
            break;
        }
        case MKTypeEncodingLong: {
            return BlockReturnSelector(longValue);
            break;
        }
        case MKTypeEncodingLongLong: {
            return BlockReturnSelector(longLongValue);
            break;
        }
        case MKTypeEncodingUnsignedChar: {
            return BlockReturnSelector(unsignedCharValue);
            break;
        }
        case MKTypeEncodingUnsignedInt: {
            return BlockReturnSelector(unsignedIntValue);
            break;
        }
        case MKTypeEncodingUnsignedShort: {
            return BlockReturnSelector(unsignedShortValue);
            break;
        }
        case MKTypeEncodingUnsignedLong: {
            return BlockReturnSelector(unsignedLongValue);
            break;
        }
        case MKTypeEncodingUnsignedLongLong: {
            return BlockReturnSelector(unsignedLongValue);
            break;
        }
        case MKTypeEncodingFloat: {
            return BlockReturnSelector(floatValue);
            break;
        }
        case MKTypeEncodingDouble: {
            return BlockReturnSelector(doubleValue);
            break;
        }
        case MKTypeEncodingCBool: {
            return BlockReturnSelector(boolValue);
            break;
        }
        case MKTypeEncodingCString:
        case MKTypeEncodingSelector:
        case MKTypeEncodingPointer: {
            return BlockReturnSelector(pointerValue);
            break;
        }
        case MKTypeEncodingStruct:
        case MKTypeEncodingUnion:
        case MKTypeEncodingBitField:
        case MKTypeEncodingArray: {
            // Get return size of method
            NSUInteger returnSize;
            NSGetSizeAndAlignment(self.method.signature.methodReturnType, &returnSize, NULL);


            if (returnSize == sizeof(NSRange)) {
                return BlockReturnSelector(rangeValue);
            }

            // Skip CGVector, CGSize
            else if (returnSize == sizeof(CGPoint)) {
                return BlockReturnSelector(CGPointValue);
            }
            else if (returnSize == sizeof(CGRect)) {
                return BlockReturnSelector(CGRectValue);
            }
            else if (returnSize == sizeof(CGAffineTransform)) {
                return BlockReturnSelector(CGAffineTransformValue);
            }

            // Skip UIOffset
            else if (returnSize == sizeof(UIEdgeInsets)) {
                return BlockReturnSelector(UIEdgeInsetsValue);
            }

            else if (returnSize == sizeof(CATransform3D)) {
                return BlockReturnSelector(CATransform3DValue);
            }

            else {
                [NSException raise:NSInternalInconsistencyException format:@"Unsupported return type hook"];
                return nil;
            }

            break;
        }
        case MKTypeEncodingObjcObject:
        case MKTypeEncodingObjcClass: {
            return BlockReturn(self.hookedReturnValue.value);
            break;
        }
    }
}

- (IMP)IMPForHookedArguments {
    NSParameterAssert(self.hookedArguments);

    if (!self.hookedArguments.count) {
        return self.originalImplementation;
    }

    for (TBValue *value in self.hookedArguments) {
        if (value.type == TBValueTypeFloat || value.type == TBValueTypeDouble) {
            return (IMP)TBTrampolineFP;
        }
    }

    return (IMP)TBTrampoline;
}

@end
