//
//  TBValueHookSectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBSectionController.h"
#import "TBValueCells.h"
@class TBSwitchCell;


typedef NS_ENUM(NSUInteger, TBHookRow) {
    TBHookRowToggle = 0,
    TBHookRowTypePicker,
    TBHookRowValueHolder
};

#pragma mark - TBValueHookSectionDelegate
@protocol TBValueHookSectionDelegate <TBTextViewCellResizing, TBSectionControllerDelegate>
@end

/// Manages a TBValue for a given value override,
/// as well as returns and configures cells for that section
#pragma mark - TBValueHookSectionController
@interface TBValueHookSectionController : TBSectionController <TBValueCellDelegate> {
    @protected
    TBValue *_hookedValue;
    const char *_typeEncoding;
}

+ (instancetype)delegate:(id<TBValueHookSectionDelegate>)delegate signature:(NSMethodSignature *)signature;

#pragma mark Internal
- (BOOL)shouldHighlightRow:(TBHookRow)row;
- (TBSwitchCell *)toggleForParameterAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, readonly) id<TBValueHookSectionDelegate> delegate;

@property (nonatomic, readonly) TBValue *hookedValue;
@property (nonatomic, readonly) NSMethodSignature *signature;
@property (nonatomic, readonly) const char *typeEncoding;

// Subclasses override
@property (nonatomic, readonly) NSString *typePickerTitle;

#pragma mark TBValueCellDelegate
@property (nonatomic) NSDate *date;
@property (nonatomic) NSString *string;
@property (nonatomic) NSNumber *number;
@property (nonatomic) NSNumber *integer;
@property (nonatomic) NSNumber *singleFloat;
@property (nonatomic) NSNumber *doubleFloat;
@property (nonatomic) NSString *chirpString;

@property (nonatomic) UIResponder *currentResponder;
/// May change as user chooses new type
@property (nonatomic) TBValueType valueType;

@end
