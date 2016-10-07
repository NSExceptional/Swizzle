//
//  MKSimpleMethod.h
//  MirrorKit
//
//  Created by Tanner on 7/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MKSimpleMethod : NSObject {
@protected
    SEL      _selector;
    NSString *_selectorString;
    NSString *_typeEncoding;
    IMP      _implementation;
}

/// Constructs and returns an \c MKSimpleMethod instance with the given name, type encoding, and implementation.
+ (instancetype)buildMethodNamed:(NSString *)name withTypes:(NSString *)typeEncoding implementation:(IMP)implementation;

/// The selector of the method.
@property (nonatomic, readonly) SEL      selector;
/// The selector string of the method.
@property (nonatomic, readonly) NSString *selectorString;
/// The type encoding of the method.
@property (nonatomic, readonly) NSString *typeEncoding;
/// The implementation of the method.
@property (nonatomic, readonly) IMP      implementation;

@end
