//
//  TBKeyPath.m
//  TBTweakViewController
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBKeyPath.h"


@implementation TBKeyPath

+ (instancetype)bundle:(TBToken *)bundle class:(TBToken *)cls method:(TBToken *)method isInstance:(NSNumber *)instance {
    TBKeyPath *keyPath  = [self new];
    keyPath->_bundleKey = bundle;
    keyPath->_classKey  = cls;
    keyPath->_methodKey = method;

    keyPath->_instanceMethods = instance;

    return keyPath;
}

@end
