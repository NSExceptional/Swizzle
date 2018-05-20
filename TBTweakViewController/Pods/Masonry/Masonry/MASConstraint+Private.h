//
//  SWZConstraint+Private.h
//  Masonry
//
//  Created by Nick Tymchenko on 29/04/14.
//  Copyright (c) 2014 cloudling. All rights reserved.
//

#import "MASConstraint.h"

@protocol SWZConstraintDelegate;


@interface SWZConstraint ()

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *	Usually SWZConstraintMaker but could be a parent SWZConstraint
 */
@property (nonatomic, weak) id<SWZConstraintDelegate> delegate;

/**
 *  Based on a provided value type, is equal to calling:
 *  NSNumber - setOffset:
 *  NSValue with CGPoint - setPointOffset:
 *  NSValue with CGSize - setSizeOffset:
 *  NSValue with MASEdgeInsets - setInsets:
 */
- (void)setLayoutConstantWithValue:(NSValue *)value;

@end


@interface SWZConstraint (Abstract)

/**
 *	Sets the constraint relation to given NSLayoutRelation
 *  returns a block which accepts one of the following:
 *    SWZViewAttribute, UIView, NSValue, NSArray
 *  see readme for more details.
 */
- (SWZConstraint * (^)(id, NSLayoutRelation))equalToWithRelation;

/**
 *	Override to set a custom chaining behaviour
 */
- (SWZConstraint *)addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end


@protocol SWZConstraintDelegate <NSObject>

/**
 *	Notifies the delegate when the constraint needs to be replaced with another constraint. For example
 *  A SWZViewConstraint may turn into a SWZCompositeConstraint when an array is passed to one of the equality blocks
 */
- (void)constraint:(SWZConstraint *)constraint shouldBeReplacedWithConstraint:(SWZConstraint *)replacementConstraint;

- (SWZConstraint *)constraint:(SWZConstraint *)constraint addConstraintWithLayoutAttribute:(NSLayoutAttribute)layoutAttribute;

@end
