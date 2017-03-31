//
//  TBCollectionViewController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/31/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBObjectCreationViewController.h"
#import "TBValue.h"


@protocol Collection <NSCopying, NSMutableCopying, NSFastEnumeration>
@property (nonatomic, readonly) NSUInteger count;
- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (void)removeAllObjects;
@end

/// Initial values must contain an object conforming to Collection.
/// Usually, it can be any mutable Foundation collection other than
/// NSMutableDictionary.
@interface TBCollectionViewController : TBObjectCreationViewController

+ (instancetype)withCompletion:(void(^)(id<Collection> result))completion
                  initialValue:(TBValue *)value;

@end
