//
//  TBTextFieldCell.h
//  TBTweakViewController
//
//  Created by Tanner on 3/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBBaseValueCell.h"


#pragma mark - TBTextFieldCell
@interface TBTextFieldCell : TBBaseValueCell <UITextFieldDelegate>

#pragma mark Public
@property (nonatomic) NSString *text;

@property (nonatomic, readonly) TBValue *selectorValue;
@property (nonatomic, readonly) TBValue *classValue;

#pragma mark Internal
@property (nonatomic, readonly) UITextField *textField;

@end
