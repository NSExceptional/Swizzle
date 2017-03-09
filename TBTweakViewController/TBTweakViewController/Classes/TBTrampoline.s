//
//  TBTrampoline.s
//  SwizzleTest
//
//  Created by Tanner on 11/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

.text
.global _TBTrampoline
.global _TBTrampolineFP
.align 4

#if __arm64__
_TBTrampolineFP:
    mov     x9, 0xbabefeeddeadbeef
    b       _TBTrampoline

_TBTrampoline:
    // Prologue
    stp     x29, x30, [sp, #-16]!       // Save fp and lr
    mov     x29, sp                     // (x29 is frame pointer, not fp)

    // Save general purpose registers
    stp     x8, x9, [sp, #-16]!        // Struct return storage address and floating-point flag
    stp     x6, x7, [sp, #-16]!
    stp     x4, x5, [sp, #-16]!
    stp     x2, x3, [sp, #-16]!
    stp     x0, x1, [sp, #-16]!

    // Maybe skip save Floating-point registers
    cmp     x9, 0xbabefeeddeadbeef
    b.ne    landing_func_call

    // Save Floating-point registers
    stp     s6, s7, [sp, #-16]!
    stp     s4, s5, [sp, #-16]!
    stp     s2, s3, [sp, #-16]!
    stp     s0, s1, [sp, #-16]!

landing_func_call:

    // self and _cmd already in
    // x0 and x1, as arg0 and arg1
    //
    // TBTrampolineLanding(self, _cmd, stackArgs, GPRegisters)
    add     x2, x29, #16                // Stack arguments in r2
    mov     x3, sp                      // General purpose registers in r3
    bl      TBTrampolineLanding         // Replace arguments, get original IMP

    // Save original IMP in x10
    mov     x10, x0

    // Maybe skip restore Floating-point registers
    cmp     x9, 0xbabefeeddeadbeef
    b.ne    restore_gp_registers

    // Restore Floating-point registers
    ldp     s0, s1, [sp], #16
    ldp     s2, s3, [sp], #16
    ldp     s4, s5, [sp], #16
    ldp     s6, s7, [sp], #16

restore_gp_registers:
    // Restore general purpose registers
    ldp     x0, x1, [sp], #16
    ldp     x2, x3, [sp], #16
    ldp     x4, x5, [sp], #16
    ldp     x6, x7, [sp], #16
    ldp     x8, x9, [sp], #16

    // Epilogue
    mov     sp, x29
    ldp     x29, x30, [sp], #16         // `[sp], #16` loads at sp then adds 16 to sp

    // Call original method
    b       x10

#elif __arm__
_TBTrampoline:
    // Prologue
    push    {r7, lr}
    mov     r7, sp          // Frame pointer

    // Save argument registers
    push {r3, r2, r1, r0}

    sub     sp, sp, #16     // Allocate 8 bytes for `size`
    mov     r2, sp          // &size in r2 as arg2 to _TBTrampolineArgBufferMake()
    // self and _cmd already in r0 and x1 as arg0 and arg1

    bl      _TBTrampolineLanding  // Make arguments buffer
    mov     r2, r8                      // `buffer` in r2
    ldr     r3, [r7, #8]                // `size` in r3

    add     sp, sp, #16     // Point sp back


    // Copy method arguments into buffer (TODO)

    // Epilogue
    mov     sp, r7
    pop     {r7, lr}

    // Jump back to Objc land
    b       _TBTrampolineLanding

#elif TARGET_OS_SIMULATOR
_TBTrampoline:
//    mov     x29, sp         // Frame pointer
//    sub     sp, sp, #8      // Allocate 8 bytes for `size`
//    sub     x2, x29, #8     // &size in r2 as arg2 to _TBTrampolineArgBufferMake()
//    // self and _cmd already in r0 and x1 as arg0 and arg1
//
//    bl      _TBTrampolineArgBufferMake  // Make arguments buffer
//    mov     x2, x8                      // `buffer` in r2
//    ldr     x3, [x29, #8]               // `size` in r3
//
//
//    // Copy method arguments into buffer (TODO)
//
//    // Jump back to Objc land
    jmp     _TBTrampolineLanding
#endif
