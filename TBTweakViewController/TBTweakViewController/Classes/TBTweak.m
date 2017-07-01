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


@interface TBTweak () {
    NSMutableArray<TBMethodHook*> *_hooks;
}
@end

@implementation TBTweak

#pragma mark Initialization

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
    TBMethodStoreRemove(hook.originalImplementation);

    Class cls = NSClassFromString(hook.target);
    [cls replaceImplementationOfMethod:hook.method with:hook.originalImplementation];
}

#pragma mark Public interface

- (void)tryEnable:(void (^)(NSError *))callback {
    NSAssert(!self.enabled, @"Cannot enable tweak that is already enabled");
    _enabled = YES;

    __block NSError *error   = nil;
    NSMutableArray *setHooks = [NSMutableArray array];

    [self.hooks enumerateObjectsUsingBlock:^(TBMethodHook *hook, NSUInteger idx, BOOL *stop) {
        [hook getImplementation:^(IMP implementation, NSError *_error) {
            if (implementation) {
                // Check if already set
                if (TBMethodStoreGet(hook.originalImplementation)) {
                    *stop    = YES;
                    _enabled = NO;
                    error    = [NSError error:@"You can only hook a method once."];
                } else {
                    TBMethodStorePut(hook.originalImplementation, hook);
                    Class cls = NSClassFromString(hook.target);
                    [cls replaceImplementationOfMethod:hook.method with:implementation];
                    [setHooks addObject:cls];
                }
            } else {
                assert(error);
                *stop    = YES;
                _enabled = NO;
                error    = _error;
            }
        }];
    }];

    // Unset all set hooks if one failed to be set
    // and callback with the associated error
    if (!_enabled) {
        for (TBMethodHook *hook in setHooks) {
            [self unsetHook:hook];
        }

        callback(error);
    }
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
