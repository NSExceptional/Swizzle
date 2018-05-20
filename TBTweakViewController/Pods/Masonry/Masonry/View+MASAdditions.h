//
//  UIView+MASAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASUtilities.h"
#import "MASConstraintMaker.h"
#import "MASViewAttribute.h"

/**
 *	Provides constraint maker block
 *  and convience methods for creating SWZViewAttribute which are view + NSLayoutAttribute pairs
 */
@interface MAS_VIEW (MASAdditions)

/**
 *	following properties return a new SWZViewAttribute with current view and appropriate NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__left;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__top;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__right;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__bottom;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__leading;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__trailing;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__width;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__height;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__centerX;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__centerY;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__baseline;
@property (nonatomic, strong, readonly) SWZViewAttribute *(^mas__attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) SWZViewAttribute *mas__firstBaseline;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) SWZViewAttribute *mas__leftMargin;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__rightMargin;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__topMargin;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__bottomMargin;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__leadingMargin;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__trailingMargin;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__centerXWithinMargins;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) SWZViewAttribute *mas__safeAreaLayoutGuide API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

/**
 *	a key to associate with this view
 */
@property (nonatomic, strong) id mas__key;

/**
 *	Finds the closest common superview between this view and another view
 *
 *	@param	view	other view
 *
 *	@return	returns nil if common superview could not be found
 */
- (instancetype)mas__closestCommonSuperview:(MAS_VIEW *)view;

/**
 *  Creates a SWZConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created SWZConstraints
 */
- (NSArray *)mas__makeConstraints:(void(NS_NOESCAPE ^)(SWZConstraintMaker *make))block;

/**
 *  Creates a SWZConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  If an existing constraint exists then it will be updated instead.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated SWZConstraints
 */
- (NSArray *)mas__updateConstraints:(void(NS_NOESCAPE ^)(SWZConstraintMaker *make))block;

/**
 *  Creates a SWZConstraintMaker with the callee view.
 *  Any constraints defined are added to the view or the appropriate superview once the block has finished executing.
 *  All constraints previously installed for the view will be removed.
 *
 *  @param block scope within which you can build up the constraints which you wish to apply to the view.
 *
 *  @return Array of created/updated SWZConstraints
 */
- (NSArray *)mas__remakeConstraints:(void(NS_NOESCAPE ^)(SWZConstraintMaker *make))block;

@end
