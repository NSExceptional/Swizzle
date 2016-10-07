//
//  NSString+Utilities.m
//  MirrorKit
//
//  Created by Tanner on 7/1/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "NSString+Utilities.h"
#import "MirrorKit-Constants.h"

@implementation NSString (Utilities)

- (NSString *)stringbyDeletingCharacterAtIndex:(NSUInteger)idx {
    NSMutableString *string = self.mutableCopy;
    [string replaceCharactersInRange:NSMakeRange(idx, 1) withString:@""];
    return string;
}

- (NSDictionary *)propertyAttributes {
    if (!self.length) return nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    NSArray *components = [self componentsSeparatedByString:@","];
    for (NSString *attribute in components) {
        MKPropertyAttribute c = (MKPropertyAttribute)[attribute characterAtIndex:0];
        switch (c) {
            case MKPropertyAttributeTypeEncoding:
                attributes[MKPropertyAttributeKeyTypeEncoding] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case MKPropertyAttributeBackingIVarName:
                attributes[MKPropertyAttributeKeyBackingIVarName] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case MKPropertyAttributeCopy:
                attributes[MKPropertyAttributeKeyCopy] = @YES;
                break;
            case MKPropertyAttributeCustomGetter:
                attributes[MKPropertyAttributeKeyCustomGetter] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case MKPropertyAttributeCustomSetter:
                attributes[MKPropertyAttributeKeyCustomSetter] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case MKPropertyAttributeDynamic:
                attributes[MKPropertyAttributeKeyDynamic] = @YES;
                break;
            case MKPropertyAttributeGarbageCollectible:
                attributes[MKPropertyAttributeKeyGarbageCollectible] = @YES;
                break;
            case MKPropertyAttributeNonAtomic:
                attributes[MKPropertyAttributeKeyNonAtomic] = @YES;
                break;
            case MKPropertyAttributeOldTypeEncoding:
                attributes[MKPropertyAttributeKeyOldTypeEncoding] = [attribute stringbyDeletingCharacterAtIndex:0];
                break;
            case MKPropertyAttributeReadOnly:
                attributes[MKPropertyAttributeKeyReadOnly] = @YES;
                break;
            case MKPropertyAttributeRetain:
                attributes[MKPropertyAttributeKeyRetain] = @YES;
                break;
            case MKPropertyAttributeWeak:
                attributes[MKPropertyAttributeKeyWeak] = @YES;
                break;
            default:
                return nil;
                //[NSException raise:NSInternalInconsistencyException format:@"Unsupported property attribute: %c", (char)c];
                break;
        }
    }

    return attributes;
}

@end
