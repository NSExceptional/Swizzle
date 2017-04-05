//
//  TBTrampolineLanding.h
//  SwizzleTest
//
//  Created by Tanner on 11/25/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef uint8_t byte;
#define kRegisterSize sizeof(void *)
#define kArgRegStart 2
#define kArgRegCount 8

typedef struct _CallState {
    byte *stackArgs;
    uintptr_t *GPRegisters;
    double *FPRegisters;
    IMP orig;
} CallState;

/// Function to prepare trampoline landing to receive arguments. FPRegisters may be NULL.
//IMP TBTrampolineLanding(id obj, SEL sel, byte *stackArgs, uintptr_t *GPRegisters, double *FPRegisters);
void TBTrampolineLanding(id obj, SEL sel, CallState);
