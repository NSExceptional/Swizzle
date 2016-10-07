//
//  MKIVar.h
//  MirrorKit
//
//  Created by Tanner on 6/30/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MirrorKit-Constants.h"
@import ObjectiveC;


@interface MKIVar : NSObject

+ (instancetype)ivar:(Ivar)ivar;

/// The underlying \c Ivar data structure.
@property (nonatomic, readonly) Ivar           objc_ivar;

/// The name of the instance variable.
@property (nonatomic, readonly) NSString       *name;
/// The type of the instance variable.
@property (nonatomic, readonly) MKTypeEncoding type;
/// The type encoding string of the instance variable.
@property (nonatomic, readonly) NSString       *typeEncoding;
/// The offset of the instance variable.
@property (nonatomic, readonly) NSInteger      offset;

@end
