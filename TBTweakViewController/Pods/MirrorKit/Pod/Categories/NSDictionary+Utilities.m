//
//  NSDictionary+Utilities.m
//  MirrorKit
//
//  Created by Tanner on 7/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSDictionary+Utilities.h"
#import "MirrorKit-Constants.h"

@implementation NSDictionary (Utilities)

- (NSString *)propertyAttributesString {
    if (!self[MKPropertyAttributeKeyTypeEncoding]) return nil;
    
    NSMutableString *attributes = [NSMutableString string];
    [attributes appendFormat:@"T%@,", self[MKPropertyAttributeKeyTypeEncoding]];
    
    for (NSString *attribute in self.allKeys) {
        MKPropertyAttribute c = (MKPropertyAttribute)[attribute characterAtIndex:0];
        switch (c) {
            case MKPropertyAttributeTypeEncoding:
                break;
            case MKPropertyAttributeBackingIVarName:
                [attributes appendFormat:@"%@%@,", MKPropertyAttributeKeyBackingIVarName, self[MKPropertyAttributeKeyBackingIVarName]];
                break;
            case MKPropertyAttributeCopy:
                if ([self[MKPropertyAttributeKeyCopy] boolValue])
                [attributes appendFormat:@"%@,", MKPropertyAttributeKeyCopy];
                break;
            case MKPropertyAttributeCustomGetter:
                [attributes appendFormat:@"%@%@,", MKPropertyAttributeKeyCustomGetter, self[MKPropertyAttributeKeyCustomGetter]];
                break;
            case MKPropertyAttributeCustomSetter:
                [attributes appendFormat:@"%@%@,", MKPropertyAttributeKeyCustomSetter, self[MKPropertyAttributeKeyCustomSetter]];
                break;
            case MKPropertyAttributeDynamic:
                if ([self[MKPropertyAttributeKeyDynamic] boolValue])
                [attributes appendFormat:@"%@,", MKPropertyAttributeKeyDynamic];
                break;
            case MKPropertyAttributeGarbageCollectible:
                [attributes appendFormat:@"%@,", MKPropertyAttributeKeyGarbageCollectible];
                break;
            case MKPropertyAttributeNonAtomic:
                if ([self[MKPropertyAttributeKeyNonAtomic] boolValue])
                [attributes appendFormat:@"%@,", MKPropertyAttributeKeyNonAtomic];
                break;
            case MKPropertyAttributeOldTypeEncoding:
                [attributes appendFormat:@"%@%@,", MKPropertyAttributeKeyOldTypeEncoding, self[MKPropertyAttributeKeyOldTypeEncoding]];
                break;
            case MKPropertyAttributeReadOnly:
                if ([self[MKPropertyAttributeKeyReadOnly] boolValue])
                [attributes appendFormat:@"%@,", MKPropertyAttributeKeyReadOnly];
                break;
            case MKPropertyAttributeRetain:
                if ([self[MKPropertyAttributeKeyRetain] boolValue])
                [attributes appendFormat:@"%@,", MKPropertyAttributeKeyRetain];
                break;
            case MKPropertyAttributeWeak:
                if ([self[MKPropertyAttributeKeyWeak] boolValue])
                [attributes appendFormat:@"%@,", MKPropertyAttributeKeyWeak];
                break;
            default:
                return nil;
                //[NSException raise:NSInternalInconsistencyException format:@"Unsupported property attribute: %c", (char)c];
                break;
        }
    }
    
    [attributes deleteCharactersInRange:NSMakeRange(attributes.length-1, 1)];
    return attributes.copy;
}

@end
