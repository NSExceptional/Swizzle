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

#pragma mark - TBValueSectionDelegate
@protocol TBValueSectionDelegate <TBTextViewCellResizing, TBSectionControllerDelegate>
@end

/// Manages a TBValue for a given value override,
/// as well as returns and configures cells for that section
#pragma mark - TBValueSectionController
@interface TBValueSectionController : TBSectionController <TBValueCellDelegate> {
    @protected
    TBValue *_container;
    const char *_typeEncoding;
}

+ (instancetype)delegate:(id<TBValueSectionDelegate>)delegate type:(const char *)typeEncoding;

#pragma mark Internal
- (BOOL)shouldHighlightRow:(TBValueRow)row;

#pragma mark Subclass overrides
- (void)didSelectValueHolderCell;
@property (nonatomic, readonly) NSString *typePickerTitle;

#pragma mark Properties
@property (nonatomic, readonly) id<TBValueSectionDelegate> delegate;

@property (nonatomic, readonly) TBValue *container;
@property (nonatomic, readonly) const char *typeEncoding;

#pragma mark TBValueCellDelegate
@property (nonatomic) NSDate *date;
@property (nonatomic) UIColor *color;
@property (nonatomic) NSString *string;
@property (nonatomic) NSNumber *number;
@property (nonatomic) NSNumber *integer;
@property (nonatomic) NSNumber *singleFloat;
@property (nonatomic) NSNumber *doubleFloat;
@property (nonatomic) NSString *chirpString;

/// May change as user chooses new type
@property (nonatomic) TBValueType valueType;

@end
