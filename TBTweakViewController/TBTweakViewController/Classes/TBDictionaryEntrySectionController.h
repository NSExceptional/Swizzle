//
//  TBDictionaryEntrySectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/30/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBSectionController.h"
#import "TBValueCells.h"


#pragma mark - TBDictionaryEntrySectionController -
@interface TBDictionaryEntrySectionController : TBSectionController

@property (nonatomic, readonly) id key;
@property (nonatomic, readonly) id value;

@end
