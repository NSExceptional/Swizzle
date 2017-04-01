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


NSString * const kLoadTweaksAtLaunch = @"TBTweaksLoadTweaksAtLaunch";


@interface TBTweak ()
@property (nonatomic, readonly) BOOL loadTweaksAtLaunch;
@property (nonatomic, readonly) NSString *methodDescription;
@end

@implementation TBTweak

- (NSString *)sortByThis {
    if (_methodDescription) {
        return _methodDescription;
    }

    _methodDescription = self.hook.method.fullName;
    return _methodDescription;
}

#pragma mark Initialization

+ (void)initialize {
    if (self == [self class]) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{kLoadTweaksAtLaunch: @YES}];
    }
}

+ (instancetype)tweakWithHook:(TBMethodHook *)hook {
    return [[self alloc] initWithHook:hook];
}

+ (instancetype)tweakWithTarget:(Class)target instanceMethod:(SEL)action {
    return [self tweakWithHook:[TBMethodHook target:target action:action isClassMethod:NO]];
}

+ (instancetype)tweakWithTarget:(Class)target method:(SEL)action {
    return [self tweakWithHook:[TBMethodHook target:target action:action isClassMethod:YES]];
}

- (id)initWithHook:(TBMethodHook *)hook {
    if (!hook) { return nil; }
    
    self = [super init];
    if (self) {
        _hook = hook;
    }
    
    return self;
}

- (BOOL)loadTweaksAtLaunch {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kLoadTweaksAtLaunch];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    // Get hook and state
    BOOL enabled       = [decoder decodeBoolForKey:@"enabled"];
    TBMethodHook *hook = [decoder decodeObjectForKey:@"hook"];
    
    // Failure decoding
    if (!hook) {
        return nil;
    }
    
    self = [self initWithHook:hook];
    if (self && enabled && self.loadTweaksAtLaunch) {
        // Re-enable
        [self tryEnable:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error enabling tweak: %@", error.localizedDescription);
            }
        }];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeBool:self.enabled forKey:@"enabled"];
    [coder encodeObject:self.hook forKey:@"hook"];
}

#pragma mark Public interface

- (void)tryEnable:(void (^)(NSError *))callback {
    NSAssert(!self.enabled, @"Cannot enable tweak that is already enabled");
    
    [self.hook getImplementation:^(IMP _Nullable implementation, NSError * _Nullable error) {
        if (implementation) {
            // Check if already set
            if (TBMethodStoreGet(self.hook.method.objc_method)) {
                callback([NSError error:@"You can only hook a method once."]);
            } else {
                TBMethodStorePut(self.hook.method.objc_method, self.hook);
                Class cls = NSClassFromString(self.hook.target);
                [cls replaceImplementationOfMethod:self.hook.method with:implementation];
                _enabled = YES;
            }
        } else {
            assert(error);
            callback(error);
        }
    }];
}

- (void)disable {
    NSAssert(self.enabled, @"Cannot disable tweak that is not enabled");
    TBMethodStoreRemove(self.hook.method.objc_method);
    
    Class cls = NSClassFromString(self.hook.target);
    [cls replaceImplementationOfMethod:self.hook.method with:self.hook.originalImplementation];
    _enabled = NO;
}

#pragma mark Equality

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[TBTweak class]])
        return [self isEqualToTweak:object];
    
    return [super isEqual:object];
}

- (BOOL)isEqualToTweak:(TBTweak *)tweak {
    return [self.hook isEqual:tweak.hook];
}

- (NSUInteger)hash {
    return self.hook.hash;
}

@end
