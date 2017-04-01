//
//  TBTweakTypeSectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 10/9/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBSectionController.h"
#import "TBSwitchCell.h"
#import "TBTweak.h"


@protocol TBTweakTypeSectionDelegate <TBSectionControllerDelegate>

@property (nonatomic, readonly) BOOL canOverrideReturnValue;
@property (nonatomic, readonly) BOOL canOverrideAllArgumentValues;
@property (nonatomic          ) TBTweakType tweakType;
@property (nonatomic, readonly) NSUInteger totalNumberOfSections;
@property (nonatomic, readonly) NSUInteger hookArgumentCount;

@end

/// Controller for the tweak config section that
/// controls the type of override (return value, args, chirp)
@interface TBTweakTypeSectionController : TBSectionController

+ (instancetype)delegate:(id<TBTweakTypeSectionDelegate>)delegate;

@property (nonatomic, readonly) BOOL overrideReturnValue;
@property (nonatomic, readonly) BOOL overrideArguments;
@property (nonatomic, readonly) BOOL overrideWithChirp;

@end
