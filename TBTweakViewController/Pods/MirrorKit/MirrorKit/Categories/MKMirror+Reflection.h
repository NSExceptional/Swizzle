//
//  MKMirror+Reflection.h
//  Pods
//
//  Created by Tanner on 3/26/17.
//
//

#import "MKMirror.h"

@interface MKMirror (Reflection)

/// @return the instance \e and class methods of the given object or class.
+ (NSArray<MKMethod*> *)allMethodsOf:(id)thing;
/// @return the instance methods of the given object or class.
+ (NSArray<MKMethod*> *)instanceMethodsOf:(id)thing;
/// @return the class methods of the given object or class.
+ (NSArray<MKMethod*> *)classMethodsOf:(id)thing;

@end
