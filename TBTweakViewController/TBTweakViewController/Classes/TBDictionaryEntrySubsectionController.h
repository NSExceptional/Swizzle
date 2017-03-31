//
//  TBDictionaryEntrySubsectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/30/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBValueSectionController.h"
@class TBDictionaryEntrySectionController;


@interface TBDictionaryEntrySubsectionController : TBValueSectionController

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate
                 section:(TBDictionaryEntrySectionController *)controller;

// Internal
@property (nonatomic, readonly) TBDictionaryEntrySectionController *section;

@end
