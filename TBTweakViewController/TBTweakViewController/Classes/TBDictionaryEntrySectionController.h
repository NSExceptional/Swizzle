//
//  TBDictionaryEntrySectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/30/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBSectionController.h"
#import "TBValueCells.h"


@protocol TBDictionarySectionDelegate <TBTextViewCellResizing, TBSectionControllerDelegate>
@end

#pragma mark - TBDictionaryEntrySectionController -
@interface TBDictionaryEntrySectionController : TBSectionController

#pragma mark Initialization
+ (instancetype)delegate:(id<TBDictionarySectionDelegate>)delegate;

#pragma mark Properties
@property (nonatomic, readonly) id<TBDictionarySectionDelegate> delegate;

@property (nonatomic, readonly) id key;
@property (nonatomic, readonly) id value;

@end
