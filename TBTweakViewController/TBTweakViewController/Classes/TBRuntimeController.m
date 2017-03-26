//
//  TBRuntimeController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBRuntimeController.h"
#import "TBRuntime.h"


@interface TBRuntimeController ()
@property (nonatomic, readonly) NSCache *bundlePathsCache;
@property (nonatomic, readonly) NSCache *bundleNamesCache;
@property (nonatomic, readonly) NSCache *classNamesCache;
@property (nonatomic, readonly) NSCache *methodsCache;
@end

@implementation TBRuntimeController

#pragma mark Initialization

static TBRuntimeController *controller = nil;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [self new];
    });

    return controller;
}

- (id)init {
    self = [super init];
    if (self) {
        _bundlePathsCache = [NSCache new];
        _bundleNamesCache = [NSCache new];
        _classNamesCache  = [NSCache new];
        _methodsCache     = [NSCache new];
    }

    return self;
}

#pragma mark Public

+ (NSArray *)dataForKeyPath:(TBKeyPath *)keyPath {
    if (keyPath.bundleKey) {
        if (keyPath.classKey) {
            if (keyPath.methodKey) {
                return [[self shared] methodsForKeyPath:keyPath];
            } else {
                return [[self shared] classesForClassToken:keyPath.classKey andBundleToken:keyPath.bundleKey];
            }
        } else {
            return [[self shared] bundleNamesForToken:keyPath.bundleKey];
        }
    } else {
        return @[];
    }
}

+ (NSArray *)allBundleNames {
    return [TBRuntime runtime].imageDisplayNames;
}

#pragma mark Private

- (NSMutableArray *)bundlePathsForToken:(TBToken *)token {
    NSMutableArray *cached = [self.bundlePathsCache objectForKey:token];
    if (cached) {
        return cached;
    }

    NSMutableArray *bundles = [[TBRuntime runtime] bundlePathsForToken:token];
    [self.bundlePathsCache setObject:bundles forKey:token];
    return bundles;
}

- (NSMutableArray *)bundleNamesForToken:(TBToken *)token {
    NSMutableArray *cached = [self.bundleNamesCache objectForKey:token];
    if (cached) {
        return cached;
    }

    NSMutableArray *bundles = [[TBRuntime runtime] bundleNamesForToken:token];
    [self.bundleNamesCache setObject:bundles forKey:token];
    return bundles;
}

- (NSMutableArray *)classesForClassToken:(TBToken *)clsToken andBundleToken:(TBToken *)bundleToken {
    NSString *key = [@[bundleToken.description, clsToken.description] componentsJoinedByString:@"+"];
    NSMutableArray *cached = [self.classNamesCache objectForKey:key];
    if (cached) {
        return cached;
    }

    NSMutableArray *bundles = [self bundlePathsForToken:bundleToken];
    NSMutableArray *classes = [[TBRuntime runtime] classesForToken:clsToken inBundles:bundles];

    [self.classNamesCache setObject:classes forKey:key];
    return classes;
}

- (NSMutableArray *)methodsForKeyPath:(TBKeyPath *)keyPath {
    NSMutableArray *cached = [self.bundleNamesCache objectForKey:keyPath];
    if (cached) {
        return cached;
    }

    NSMutableArray *classes = [self classesForClassToken:keyPath.classKey andBundleToken:keyPath.bundleKey];
    NSMutableArray *methods = [[TBRuntime runtime] methodsForToken:keyPath.methodKey
                                                          instance:keyPath.instanceMethods
                                                          inClasses:classes];
    [self.bundleNamesCache setObject:methods forKey:keyPath];
    return methods;
}

@end
