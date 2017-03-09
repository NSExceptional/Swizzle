//
//  TBTrampoline.h
//  SwizzleTest
//
//  Created by Tanner on 11/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "TargetConditionals.h"


/// @brief Trampoline function for method hooks.
///
/// This function becomes the implementation of
/// any method which only hooks arguments. It will
/// call into one of the TBTrampolineLanding
/// functions, which replaces hooked arguments and
/// returns the original IMP, then it will call
/// into the original IMP just as objc_msgSend does.
void TBTrampoline(id receiver, SEL _cmd, ...);

/// @brief Trampoline function for method hooks.
///
/// Like TBTrampoline, but for methods which
/// take Floating-point arguments or HFAs. TBTrampoline
/// itself does not automatically handle FP registers.
void TBTrampolineFP(id receiver, SEL _cmd, ...);
