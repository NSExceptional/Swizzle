//
//  MKIVar.m
//  MirrorKit
//
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "MKIVar.h"


@implementation MKIVar

- (id)init { [NSException raise:NSInternalInconsistencyException format:@"Class instance should not be created with -init"]; return nil; }

#pragma mark Initializers
+ (instancetype)ivar:(Ivar)ivar {
    return [[self alloc] initWithIVar:ivar];
}

- (id)initWithIVar:(Ivar)ivar {
    NSParameterAssert(ivar);
    
    self = [super init];
    if (self) {
        _objc_ivar = ivar;
        [self examine];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ name=%@, encoding=%@, offset=%ld>",
            NSStringFromClass(self.class), self.name, self.typeEncoding, (long)self.offset];
}

- (void)examine {
    _name         = @(ivar_getName(self.objc_ivar));
    _typeEncoding = @(ivar_getTypeEncoding(self.objc_ivar));
    _type         = (MKTypeEncoding)[_typeEncoding characterAtIndex:0];
    _offset       = ivar_getOffset(self.objc_ivar);
}

@end
