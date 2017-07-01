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
.global _originalIMP
.global _landingIMP
.global _TBTrampolineEnd
.align 4

#if __arm64__
_TBTrampolineFP:
    // FP denoted by x12 == x9 == 0xbabefeeddeadbeef
    movz	x9, #0xbabe, lsl #48
    movk	x9, #0xfeed, lsl #32
    movk	x9, #0xdead, lsl #16
    movk	x9, #0xbeef
    mov     x12, x9
    b       _TBTrampoline

_TBTrampoline:
    // Prologue
    stp     x29, x30, [sp, #-16]!       // Save fp and lr
    mov     x29, sp                     // (x29 is frame pointer, not fp)

    // Save general purpose registers
    stp     x8, x9, [sp, #-16]!         // x8 for struct return addr and x9 for Floating-point flag
    stp     x6, x7, [sp, #-16]!
    stp     x4, x5, [sp, #-16]!
    stp     x2, x3, [sp, #-16]!
    stp     x0, x1, [sp, #-16]!
    mov     x3, sp                      // General purpose registers in r3
    sub     x4, x4, x4                  // NULL in r4 in case not FP (set below if FP)

    // Maybe skip save Floating-point registers
    cmp     x9, x12
    b.ne    landing_func_call
    // Double check (edge case: x9 and x12 are equal but not magic)
    movz	x9, #0xbabe, lsl #48
    movk	x9, #0xfeed, lsl #32
    movk	x9, #0xdead, lsl #16
    movk	x9, #0xbeef
    cmp     x9, x12
    b.ne    landing_func_call

    // Save Floating-point registers
    stp     s6, s7, [sp, #-16]!
    stp     s4, s5, [sp, #-16]!
    stp     s2, s3, [sp, #-16]!
    stp     s0, s1, [sp, #-16]!
    mov     x4, sp                      // Floating-point registers in r4

landing_func_call:

    stp     xzr, x4, [sp, #-16]!        // Save x4 as new Floating-point flag

    ldr     x10, _originalIMP           // orig in x10
    add     x2, x29, #16                // Stack arguments in x2

    // CallState callState = { x2, x3, x4, x10 };
    stp     x4, x10, [sp, #-16]!
    stp     x2,  x3, [sp, #-16]!
    add     x2,  sp, #0                 // x2 = &callState

    // Replace arguments
    //
    // self and _cmd already in
    // x0 and x1, as arg0 and arg1
    //
    // TBTrampolineLanding(self, _cmd, &callState)
    ldr     x10, _landingIMP            // Load absolute address of TBTrampolineLanding
    blr     x10

    // TODO cleanup callState allocation,
    // then make sure x4 is restored properly
    add     sp, sp, #32

    // Maybe skip restore Floating-point registers
    ldp     xzr, x4, [sp], #16          // Load x4 from stack
    movz    x9, #0                      // Prepare to compare to x9
    cmp     x4, x9                      // if (flag == 0) ...
    b.eq    restore_gp_registers        //     restore GP registers

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
    ldr     x10, _originalIMP           // Load it again, x10 may be clobbered
    br      x10

_originalIMP:
    nop
    nop
_landingIMP:
    nop
    nop
_TBTrampolineEnd:
    nop


#elif !__arm__
_TBTrampolineFP:
    xorl    %edi, %edi
    callq   _exit
_TBTrampoline:
    xorl    %edi, %edi
    callq   _exit

_originalIMP:
    nop
    nop
_landingIMP:
    nop
    nop
_TBTrampolineEnd:
    nop
#endif
