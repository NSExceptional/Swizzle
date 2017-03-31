//
//  TBValueSectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBSectionController.h"
#import "TBValueCells.h"
@class TBSwitchCell;


typedef NS_ENUM(NSUInteger, TBValueRow) {
    TBValueRowTypePicker,
    TBValueRowValueHolder
};

/// Manages a TBValue for a given value override,
/// as well as returns and configures cells for that section
#pragma mark - TBValueSectionController
@interface TBValueSectionController : TBSectionController <TBValueCellDelegate> {
    @protected
    const char *_typeEncoding;
}

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate type:(const char *)typeEncoding;

#pragma mark Internal
- (BOOL)shouldHighlightRow:(TBValueRow)row;

#pragma mark Subclass overrides
- (void)didSelectValueHolderCell:(NSUInteger)section;
@property (nonatomic, readonly) NSString *typePickerTitle;

#pragma mark Properties
@property (nonatomic, readonly) id<TBSectionControllerDelegate> delegate;
@property (nonatomic, readonly) const char *typeEncoding;

#pragma mark TBValueCellDelegate
@property (nonatomic, readonly) TBValueCoordinator *coordinator;

@end
