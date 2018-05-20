//
//  UIView+MASAdditions.m
//  Masonry
//
//  Created by Jonas Budelmann on 20/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "View+MASAdditions.h"
#import <objc/runtime.h>

@implementation MAS_VIEW (MASAdditions)

- (NSArray *)mas__makeConstraints:(void(^)(SWZConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    SWZConstraintMaker *constraintMaker = [[SWZConstraintMaker alloc] initWithView:self];
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas__updateConstraints:(void(^)(SWZConstraintMaker *))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    SWZConstraintMaker *constraintMaker = [[SWZConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

- (NSArray *)mas__remakeConstraints:(void(^)(SWZConstraintMaker *make))block {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    SWZConstraintMaker *constraintMaker = [[SWZConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    block(constraintMaker);
    return [constraintMaker install];
}

#pragma mark - NSLayoutAttribute properties

- (SWZViewAttribute *)mas__left {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
}

- (SWZViewAttribute *)mas__top {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
}

- (SWZViewAttribute *)mas__right {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
}

- (SWZViewAttribute *)mas__bottom {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
}

- (SWZViewAttribute *)mas__leading {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
}

- (SWZViewAttribute *)mas__trailing {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
}

- (SWZViewAttribute *)mas__width {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeWidth];
}

- (SWZViewAttribute *)mas__height {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeHeight];
}

- (SWZViewAttribute *)mas__centerX {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterX];
}

- (SWZViewAttribute *)mas__centerY {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterY];
}

- (SWZViewAttribute *)mas__baseline {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBaseline];
}

- (SWZViewAttribute *(^)(NSLayoutAttribute))mas__attribute
{
    return ^(NSLayoutAttribute attr) {
        return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:attr];
    };
}

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000) || (__MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)

- (SWZViewAttribute *)mas__firstBaseline {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeFirstBaseline];
}
- (SWZViewAttribute *)mas__lastBaseline {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLastBaseline];
}

#endif

#if (__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000) || (__TV_OS_VERSION_MIN_REQUIRED >= 9000)

- (SWZViewAttribute *)mas__leftMargin {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeftMargin];
}

- (SWZViewAttribute *)mas__rightMargin {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRightMargin];
}

- (SWZViewAttribute *)mas__topMargin {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTopMargin];
}

- (SWZViewAttribute *)mas__bottomMargin {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottomMargin];
}

- (SWZViewAttribute *)mas__leadingMargin {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeadingMargin];
}

- (SWZViewAttribute *)mas__trailingMargin {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailingMargin];
}

- (SWZViewAttribute *)mas__centerXWithinMargins {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterXWithinMargins];
}

- (SWZViewAttribute *)mas__centerYWithinMargins {
    return [[SWZViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeCenterYWithinMargins];
}

#endif

#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 110000) || (__TV_OS_VERSION_MAX_ALLOWED >= 110000)

- (SWZViewAttribute *)mas__safeAreaLayoutGuide {
    return [[SWZViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (SWZViewAttribute *)mas__safeAreaLayoutGuideTop {
    return [[SWZViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (SWZViewAttribute *)mas__safeAreaLayoutGuideBottom {
    return [[SWZViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (SWZViewAttribute *)mas__safeAreaLayoutGuideLeft {
    return [[SWZViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeft];
}
- (SWZViewAttribute *)mas__safeAreaLayoutGuideRight {
    return [[SWZViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeRight];
}

#endif

#pragma mark - associated properties

- (id)mas__key {
    return objc_getAssociatedObject(self, @selector(mas__key));
}

- (void)setMas__key:(id)key {
    objc_setAssociatedObject(self, @selector(mas__key), key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - heirachy

- (instancetype)mas__closestCommonSuperview:(MAS_VIEW *)view {
    MAS_VIEW *closestCommonSuperview = nil;

    MAS_VIEW *secondViewSuperview = view;
    while (!closestCommonSuperview && secondViewSuperview) {
        MAS_VIEW *firstViewSuperview = self;
        while (!closestCommonSuperview && firstViewSuperview) {
            if (secondViewSuperview == firstViewSuperview) {
                closestCommonSuperview = secondViewSuperview;
            }
            firstViewSuperview = firstViewSuperview.superview;
        }
        secondViewSuperview = secondViewSuperview.superview;
    }
    return closestCommonSuperview;
}

@end
