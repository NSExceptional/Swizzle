//
//  SWZConstraintMaker.h
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASConstraint.h"
#import "MASUtilities.h"

typedef NS_OPTIONS(NSInteger, MASAttribute) {
    MASAttributeLeft = 1 << NSLayoutAttributeLeft,
    MASAttributeRight = 1 << NSLayoutAttributeRight,
    MASAttributeTop = 1 << NSLayoutAttributeTop,
    MASAttributeBottom = 1 << NSLayoutAttributeBottom,
    MASAttributeLeading = 1 << NSLayoutAttributeLeading,
    MASAttributeTrailing = 1 << NSLayoutAttributeTrailing,
    MASAttributeWidth = 1 << NSLayoutAttributeWidth,
    MASAttributeHeight = 1 << NSLayoutAttributeHeight,
    MASAttributeCenterX = 1 << NSLayoutAttributeCenterX,
    MASAttributeCenterY = 1 << NSLayoutAttributeCenterY,
    MASAttributeBaseline = 1 << NSLayoutAttributeBaseline,
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    
    MASAttributeFirstBaseline = 1 << NSLayoutAttributeFirstBaseline,
    MASAttributeLastBaseline = 1 << NSLayoutAttributeLastBaseline,
    
#endif
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)
    
    MASAttributeLeftMargin = 1 << NSLayoutAttributeLeftMargin,
    MASAttributeRightMargin = 1 << NSLayoutAttributeRightMargin,
    MASAttributeTopMargin = 1 << NSLayoutAttributeTopMargin,
    MASAttributeBottomMargin = 1 << NSLayoutAttributeBottomMargin,
    MASAttributeLeadingMargin = 1 << NSLayoutAttributeLeadingMargin,
    MASAttributeTrailingMargin = 1 << NSLayoutAttributeTrailingMargin,
    MASAttributeCenterXWithinMargins = 1 << NSLayoutAttributeCenterXWithinMargins,
    MASAttributeCenterYWithinMargins = 1 << NSLayoutAttributeCenterYWithinMargins,

#endif
    
};

/**
 *  Provides factory methods for creating SWZConstraints.
 *  Constraints are collected until they are ready to be installed
 *
 */
@interface SWZConstraintMaker : NSObject

/**
 *	The following properties return a new SWZViewConstraint
 *  with the first item set to the makers associated view and the appropriate SWZViewAttribute
 */
@property (nonatomic, strong, readonly) SWZConstraint *left;
@property (nonatomic, strong, readonly) SWZConstraint *top;
@property (nonatomic, strong, readonly) SWZConstraint *right;
@property (nonatomic, strong, readonly) SWZConstraint *bottom;
@property (nonatomic, strong, readonly) SWZConstraint *leading;
@property (nonatomic, strong, readonly) SWZConstraint *trailing;
@property (nonatomic, strong, readonly) SWZConstraint *width;
@property (nonatomic, strong, readonly) SWZConstraint *height;
@property (nonatomic, strong, readonly) SWZConstraint *centerX;
@property (nonatomic, strong, readonly) SWZConstraint *centerY;
@property (nonatomic, strong, readonly) SWZConstraint *baseline;

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) SWZConstraint *firstBaseline;
@property (nonatomic, strong, readonly) SWZConstraint *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) SWZConstraint *leftMargin;
@property (nonatomic, strong, readonly) SWZConstraint *rightMargin;
@property (nonatomic, strong, readonly) SWZConstraint *topMargin;
@property (nonatomic, strong, readonly) SWZConstraint *bottomMargin;
@property (nonatomic, strong, readonly) SWZConstraint *leadingMargin;
@property (nonatomic, strong, readonly) SWZConstraint *trailingMargin;
@property (nonatomic, strong, readonly) SWZConstraint *centerXWithinMargins;
@property (nonatomic, strong, readonly) SWZConstraint *centerYWithinMargins;

#endif

/**
 *  Returns a block which creates a new SWZCompositeConstraint with the first item set
 *  to the makers associated view and children corresponding to the set bits in the
 *  MASAttribute parameter. Combine multiple attributes via binary-or.
 */
@property (nonatomic, strong, readonly) SWZConstraint *(^attributes)(MASAttribute attrs);

/**
 *	Creates a SWZCompositeConstraint with type SWZCompositeConstraintTypeEdges
 *  which generates the appropriate SWZViewConstraint children (top, left, bottom, right)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) SWZConstraint *edges;

/**
 *	Creates a SWZCompositeConstraint with type SWZCompositeConstraintTypeSize
 *  which generates the appropriate SWZViewConstraint children (width, height)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) SWZConstraint *size;

/**
 *	Creates a SWZCompositeConstraint with type SWZCompositeConstraintTypeCenter
 *  which generates the appropriate SWZViewConstraint children (centerX, centerY)
 *  with the first item set to the makers associated view
 */
@property (nonatomic, strong, readonly) SWZConstraint *center;

/**
 *  Whether or not to check for an existing constraint instead of adding constraint
 */
@property (nonatomic, assign) BOOL updateExisting;

/**
 *  Whether or not to remove existing constraints prior to installing
 */
@property (nonatomic, assign) BOOL removeExisting;

/**
 *	initialises the maker with a default view
 *
 *	@param	view	any SWZConstraint are created with this view as the first item
 *
 *	@return	a new SWZConstraintMaker
 */
- (id)initWithView:(MAS_VIEW *)view;

/**
 *	Calls install method on any SWZConstraints which have been created by this maker
 *
 *	@return	an array of all the installed SWZConstraints
 */
- (NSArray *)install;

- (SWZConstraint * (^)(dispatch_block_t))group;

@end
