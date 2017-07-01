//
//  TBTrampolineLanding.m
//  SwizzleTest
//
//  Created by Tanner on 11/25/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBTrampolineLanding.h"
#import "TBTrampoline.h"
#import "MirrorKit/MirrorKit.h"
#import "TBMethodHook.h"
#import "TBValue+ValueHelpers.h"
#import "TBMethodStore.h"
#import <objc/runtime.h>


#pragma mark Macros

#define kRegisterSize sizeof(void *)
#define kArgRegStart 2
#define kArgRegCount 8

#define TBRoundUpToAlignment(toRound, roundTo) (NSUInteger)(toRound + roundTo - ((uint64_t)toRound % (uint64_t)roundTo))


#define format(...) [NSString stringWithFormat:__VA_ARGS__]
#define pfret(type, value, fsp) printf(format(@"Return type: %s value: "fsp, type, value).UTF8String)
#define pfarg(i, type, value, fsp) printf(format(@"Arg %d type: %s value: "fsp, i, type, value).UTF8String)


#pragma mark Prototypes

static inline NSString * TBHFALayoutInMemory(NSString *type);
static inline NSString * TBTypeIsHFA(const char * fullType);

#pragma mark PUBLIC

void TBTrampolineLanding(id obj, SEL sel, CallState callState) {
    byte *stackArgs = callState.stackArgs;
    double *FPRegisters = callState.FPRegisters;
    uintptr_t *GPRegisters = callState.GPRegisters;

    // Get method info
    TBMethodHook *hook            = TBMethodStoreGet(callState.orig);
    NSArray<TBValue*> *hookedArgs = hook.hookedArguments;
    assert(hook);

    // Method signature, arg count
    NSMethodSignature *signature = hook.method.signature;
    byte argc = signature.numberOfArguments;
    assert(argc > 2); assert(hookedArgs.count == argc);


    // Register allocation pointers/counters, source/destination pointers
    byte       NFRN = FPRegisters == NULL ? 8 : 0;
    byte       NGRN = kArgRegStart;
    NSUInteger NSAA = 0;


    for (NSUInteger i = 2; i < argc; i++) {
        // Grab optionally hooked-value and type signature
        TBValue *replacement = hookedArgs[i];
        const char *fullArgType = [signature getArgumentTypeAtIndex:i];
        MKTypeEncoding type = fullArgType[0];

        // Grab size and alignment
        NSUInteger size, align;
        NSGetSizeAndAlignment(fullArgType, &size, &align);

        // FP Regsiter values, skipped if FPRegisters ptr is NULL
        if (NFRN < kArgRegCount) {
            // Floating point in registers
            if (type == MKTypeEncodingFloat || type == MKTypeEncodingDouble) {
                // Works for float and double
                TBValueMemcpyIfOverride(replacement, FPRegisters + NFRN, size);
                NFRN++;
                continue;
            }

            // An HFA is astruct composed of all floats or all doubles with < 5 members
            NSString *hfa = TBTypeIsHFA(fullArgType);
            if (hfa) {
                NSUInteger hfaMemberCount = hfa.length;

                // Fits in register
                if (NFRN + hfaMemberCount <= kArgRegCount) {
                    TBValueMemcpyIfOverride(replacement, FPRegisters + NFRN, size);
                    NFRN += hfaMemberCount;
                    continue;
                }
                // Does not fit in register, no more FP register args
                // FALLS THROUGH ON PURPOSE
                else {
                    NFRN = kArgRegCount;
                    // Will adjust stack alignment below
                }
            }
        }

        // General purpose register values
        if (NGRN < kArgRegCount) {
            // Fits in one register
            if (size <= kRegisterSize) {
                // Register args where `size < 8` bytes are given a full
                // 8 byte stack slot, front-aligned, because scalar
                // values are stored in reverse-byte order in memory.
                // Example: the char value 0xC1 is stored in 8 bytes in
                // a register, and when you push said register to the
                // stack, it becomes 0xC100 0000 0000 0000. Where
                // *arg is the 0xC1 byte. This can be interpreted
                // as any scalar type by casting arg to (type*).
                // We do not need to skip over any padding. Simply
                // copy the approprite number of bytes and increment
                // source by the number of bytes copied.


                // Copy only arg length
                TBValueMemcpyIfOverride(replacement, GPRegisters + NGRN, size);
                NGRN++;
                continue;
            }

            // Fits in two registers
            if (size <= (2 * kRegisterSize)) {
                // Register args where `8 < size <= 16` bytes are given
                // two 8 byte stack slots, front-aligned in the second
                // register (TODO: check 2nd reg alignment)
                // UNLESS the argument would have been in the last register,
                // in which case it is on the stack and will affect
                // the position of following arguments according to their
                // alignment.

                // Arg was in register
                if (NGRN < 7) {

                    // Copy only arg length
                    TBValueMemcpyIfOverride(replacement, GPRegisters + NGRN, size);
                    // Arg uses two registers
                    NGRN += 2;
                }
                // Arg was on stack
                else {
                    // Copy only arg length
                    TBValueMemcpyIfOverride(replacement, stackArgs + NSAA, size);
                    // Point NSAA to next argument
                    NSAA += size;
                }

                continue;
            }

            // Large args, > 16 bytes
            //
            // Regsiter args where `size > 16` bytes are given a single
            // register which holds a reference to the arg itself.
            // TLDR: large args are passed by reference.
            void *argRef = *(void**)(GPRegisters + NGRN);
            TBValueMemcpyIfOverride(replacement, argRef, size);
            // Arg used one register
            NGRN++;
            continue;
        }

        // Stack args, alignment matters
        if (size == 1) {
            // Alignment = 1, nbd
            TBValueMemcpyIfOverride(replacement, stackArgs + NSAA, 1);
            NSAA++;
        } else {
            // Round NSAA up to alignment of type to be copied
            NSAA += TBRoundUpToAlignment(stackArgs + NSAA, align);

            TBValueMemcpyIfOverride(replacement, stackArgs + NSAA, size);
            NSAA += size;
        }
    }
}

#pragma mark Private

/// @return something like `"{CGRe_ct={C12GPoint=dd}{CGSize=dd}}"`, `"dddd"`
static inline NSString * TBHFALayoutInMemory(NSString *type) {
    NSString *layoutInMemory = methodStore.typeEncodings[type];

    if (!layoutInMemory) {
        if ([type rangeOfCharacterFromSet:HFACharacters].location == NSNotFound) {
            return nil;
        }

        NSMutableString *mType = type.mutableCopy;

        if ([mType containsString:@"="]) {
            [mType replaceOccurrencesOfString:@"(\\w[\\w\\d]+=)" withString:@""
                                      options:NSRegularExpressionSearch
                                        range:NSMakeRange(0, mType.length)];
        }

        [mType replaceOccurrencesOfString:@"{" withString:@"" options:0 range:NSMakeRange(0, mType.length)];
        [mType replaceOccurrencesOfString:@"}" withString:@"" options:0 range:NSMakeRange(0, mType.length)];

        // Must be at most 4 members
        if (mType.length > 4) {
            return nil;
        }

        // Must be all float or all double
        char c = [mType characterAtIndex:0];
        if (c != 'd' && c != 'f') {
            return nil;
        }
        for (NSUInteger i = 0; i < mType.length; i++) {
            if ([mType characterAtIndex:i] != c) {
                return nil;
            }
        }

        methodStore.typeEncodings[type] = mType;
        layoutInMemory = mType;
    }

    return layoutInMemory;
}

/// @return The HFA memory layout or nil if the type is not an HFA.
static inline NSString * TBTypeIsHFA(const char * fullType) {
    if (fullType[0] != '{') { return nil; }
    
    NSString *type = @(fullType);
    return TBHFALayoutInMemory(type);
}
