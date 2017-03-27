//
//  TBSectionController.m
//  TBTweakViewController
//
//  Created by Tanner on 10/9/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBSectionController.h"


#pragma mark Macros

#define TBAbstractImpl(thing) \
    [NSException raise:NSGenericException \
                format:@"Subclasses must override %s", sel_getName(_cmd)]; \
    return thing;


#pragma mark TBSectionController

@interface TBSectionController ()
@end

@implementation TBSectionController
@dynamic sectionRowCount;

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate {
    TBSectionController *controller = [self new];
    controller->_delegate = delegate;
    return controller;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TBAbstractImpl(nil);
}

- (BOOL)shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    TBAbstractImpl(NO);
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TBAbstractImpl();
}


@end
