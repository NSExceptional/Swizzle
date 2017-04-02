//
//  TBTweak.m
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBTweak.h"
#import "TBMethodStore.h"
#import "Categories.h"
#import "TBSettings.h"


NSString * const kLoadTweaksAtLaunch = @"TBTweaksLoadTweaksAtLaunch";


@interface TBTweak () {
    NSMutableArray<TBMethodHook*> *_hooks;
}
@property (nonatomic, readonly) BOOL loadTweaksAtLaunch;
@end

@implementation TBTweak

#pragma mark Initialization

+ (void)initialize {
    if (self == [self class]) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{kLoadTweaksAtLaunch: @YES}];
    }
}

+ (instancetype)tweakWithTitle:(NSString *)title {
    return [[self alloc] initWithTitle:title hooks:@[]];
}

- (id)initWithTitle:(NSString *)title hooks:(NSArray<TBMethodHook*> *)hooks {
    NSParameterAssert(title); NSParameterAssert(hooks);
    self = [super init];
    if (self) {
        _title = title;
        _hooks = hooks.mutableCopy;
    }
    
    return self;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    // Get hook and state
    BOOL enabled    = [decoder decodeBoolForKey:@"enabled"];
    NSArray *hooks  = [decoder decodeObjectForKey:@"hooks"];
    NSString *title = [decoder decodeObjectForKey:@"title"];
    
    // Failure decoding
    if (!hooks) {
        return nil;
    }
    
    self = [self initWithTitle:title hooks:hooks];
    if (self && enabled && TBSettings.loadTweaksAtLaunch) {
        // Re-enable
        [self tryEnable:^(NSError *error) {
            if (error) {
                NSLog(@"Error enabling tweak: %@", error.localizedDescription);
            }
        }];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.enabled forKey:@"enabled"];
    [coder encodeObject:self.hooks forKey:@"hooks"];
    [coder encodeObject:self.title forKey:@"title"];
}

#pragma mark Private

- (void)unsetHook:(TBMethodHook *)hook {
    TBMethodStoreRemove(hook.method.objc_method);

    Class cls = NSClassFromString(hook.target);
    [cls replaceImplementationOfMethod:hook.method with:hook.originalImplementation];
}

#pragma mark Public interface

- (void)tryEnable:(void (^)(NSError *))callback {
    NSAssert(!self.enabled, @"Cannot enable tweak that is already enabled");

    [self.hooks enumerateObjectsUsingBlock:^(TBMethodHook *hook, NSUInteger idx, BOOL *stop) {
        [hook getImplementation:^(IMP implementation, NSError *error) {
            if (implementation) {
                // Check if already set
                if (TBMethodStoreGet(hook.method.objc_method)) {
                    *stop = YES;
                    callback([NSError error:@"You can only hook a method once."]);
                } else {
                    TBMethodStorePut(hook.method.objc_method, hook);
                    Class cls = NSClassFromString(hook.target);
                    [cls replaceImplementationOfMethod:hook.method with:implementation];
                    _enabled = YES;
                }
            } else {
                *stop = YES;
                assert(error);
                callback(error);
            }
        }];
    }];
}

- (void)disable {
    NSAssert(self.enabled, @"Cannot disable tweak that is not enabled");

    for (TBMethodHook *hook in self.hooks) {
        [self unsetHook:hook];
    }

    _enabled = NO;
}

- (void)addHook:(TBMethodHook *)hook {
    [_hooks addObject:hook];
}

- (void)removeHook:(TBMethodHook *)hook {
    NSUInteger idx = [self.hooks indexOfObject:hook];

    if (idx != NSNotFound) {
        [_hooks removeObjectAtIndex:idx];

        if (self.enabled) {
            [self unsetHook:hook];
        }
    }
}

#pragma mark Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[TBTweak class]])
        return [self isEqualToTweak:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToTweak:(TBTweak *)tweak {
    return [self.hooks isEqual:tweak.hooks];
}

- (NSUInteger)hash {
    return self.title.hash;
}

@end
