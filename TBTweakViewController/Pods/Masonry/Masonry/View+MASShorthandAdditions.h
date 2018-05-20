//
//  UIView+MASShorthandAdditions.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "View+MASAdditions.h"

#ifdef MAS_SHORTHAND

/**
 *	Shorthand view additions without the 'mas__' prefixes,
 *  only enabled if MAS_SHORTHAND is defined
 */
@interface MAS_VIEW (MASShorthandAdditions)

@property (nonatomic, strong, readonly) SWZViewAttribute *left;
@property (nonatomic, strong, readonly) SWZViewAttribute *top;
@property (nonatomic, strong, readonly) SWZViewAttribute *right;
@property (nonatomic, strong, readonly) SWZViewAttribute *bottom;
@property (nonatomic, strong, readonly) SWZViewAttribute *leading;
@property (nonatomic, strong, readonly) SWZViewAttribute *trailing;
@property (nonatomic, strong, readonly) SWZViewAttribute *width;
@property (nonatomic, strong, readonly) SWZViewAttribute *height;
@property (nonatomic, strong, readonly) SWZViewAttribute *centerX;
@property (nonatomic, strong, readonly) SWZViewAttribute *centerY;
@property (nonatomic, strong, readonly) SWZViewAttribute *baseline;
@property (nonatomic, strong, readonly) SWZViewAttribute *(^attribute)(NSLayoutAttribute attr);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

@property (nonatomic, strong, readonly) SWZViewAttribute *firstBaseline;
@property (nonatomic, strong, readonly) SWZViewAttribute *lastBaseline;

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

@property (nonatomic, strong, readonly) SWZViewAttribute *leftMargin;
@property (nonatomic, strong, readonly) SWZViewAttribute *rightMargin;
@property (nonatomic, strong, readonly) SWZViewAttribute *topMargin;
@property (nonatomic, strong, readonly) SWZViewAttribute *bottomMargin;
@property (nonatomic, strong, readonly) SWZViewAttribute *leadingMargin;
@property (nonatomic, strong, readonly) SWZViewAttribute *trailingMargin;
@property (nonatomic, strong, readonly) SWZViewAttribute *centerXWithinMargins;
@property (nonatomic, strong, readonly) SWZViewAttribute *centerYWithinMargins;

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

@property (nonatomic, strong, readonly) SWZViewAttribute *safeAreaLayoutGuideTop API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) SWZViewAttribute *safeAreaLayoutGuideBottom API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) SWZViewAttribute *safeAreaLayoutGuideLeft API_AVAILABLE(ios(11.0),tvos(11.0));
@property (nonatomic, strong, readonly) SWZViewAttribute *safeAreaLayoutGuideRight API_AVAILABLE(ios(11.0),tvos(11.0));

#endif

- (NSArray *)makeConstraints:(void(^)(SWZConstraintMaker *make))block;
- (NSArray *)updateConstraints:(void(^)(SWZConstraintMaker *make))block;
- (NSArray *)remakeConstraints:(void(^)(SWZConstraintMaker *make))block;

@end

#define MAS_ATTR_FORWARD(attr)  \
- (SWZViewAttribute *)attr {    \
    return [self mas__##attr];   \
}

@implementation MAS_VIEW (MASShorthandAdditions)

MAS_ATTR_FORWARD(top);
MAS_ATTR_FORWARD(left);
MAS_ATTR_FORWARD(bottom);
MAS_ATTR_FORWARD(right);
MAS_ATTR_FORWARD(leading);
MAS_ATTR_FORWARD(trailing);
MAS_ATTR_FORWARD(width);
MAS_ATTR_FORWARD(height);
MAS_ATTR_FORWARD(centerX);
MAS_ATTR_FORWARD(centerY);
MAS_ATTR_FORWARD(baseline);

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

MAS_ATTR_FORWARD(firstBaseline);
MAS_ATTR_FORWARD(lastBaseline);

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

MAS_ATTR_FORWARD(leftMargin);
MAS_ATTR_FORWARD(rightMargin);
MAS_ATTR_FORWARD(topMargin);
MAS_ATTR_FORWARD(bottomMargin);
MAS_ATTR_FORWARD(leadingMargin);
MAS_ATTR_FORWARD(trailingMargin);
MAS_ATTR_FORWARD(centerXWithinMargins);
MAS_ATTR_FORWARD(centerYWithinMargins);

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

MAS_ATTR_FORWARD(safeAreaLayoutGuideTop);
MAS_ATTR_FORWARD(safeAreaLayoutGuideBottom);
MAS_ATTR_FORWARD(safeAreaLayoutGuideLeft);
MAS_ATTR_FORWARD(safeAreaLayoutGuideRight);

#endif

- (SWZViewAttribute *(^)(NSLayoutAttribute))attribute {
    return [self mas__attribute];
}

- (NSArray *)makeConstraints:(void(NS_NOESCAPE ^)(SWZConstraintMaker *))block {
    return [self mas__makeConstraints:block];
}

- (NSArray *)updateConstraints:(void(NS_NOESCAPE ^)(SWZConstraintMaker *))block {
    return [self mas__updateConstraints:block];
}

- (NSArray *)remakeConstraints:(void(NS_NOESCAPE ^)(SWZConstraintMaker *))block {
    return [self mas__remakeConstraints:block];
}

@end

#endif
