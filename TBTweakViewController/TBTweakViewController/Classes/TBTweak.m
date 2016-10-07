//
//  TBTweak.m
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBTweak.h"


NSString * const kLoadTweaksAtLaunch = @"TBTweaksLoadTweaksAtLaunch";


@interface TBTweak ()
@property (nonatomic, readonly) BOOL loadTweaksAtLaunch;
@end

@implementation TBTweak

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
            Class cls = NSClassFromString(self.hook.target);
            [cls replaceImplementationOfMethod:self.hook.method with:implementation useInstance:self.hook.method.isInstanceMethod];
            _enabled = YES;
        } else {
            assert(error);
            callback(error);
        }
    }];
}

- (void)disable {
    NSAssert(self.enabled, @"Cannot disable tweak that is not enabled");
    Class cls = NSClassFromString(self.hook.target);
    [cls replaceImplementationOfMethod:self.hook.method with:self.hook.originalImplementation
                           useInstance:self.hook.method.isInstanceMethod];
    _enabled = NO;
}

- (TBTweakType)tweakType {
    if (self.hook.chirpString) {
        return TBTweakTypeChirpCode;
    }
    if (self.hook.hookedReturnValue) {
        return TBTweakTypeHookReturnValue;
    }
    if (self.hook.hookedArguments) {
        return TBTweakTypeHookArguments;
    }
    
    return TBTweakTypeUnspecified;
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
