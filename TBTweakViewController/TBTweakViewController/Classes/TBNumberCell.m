//
//  TBNumberCell.m
//  TBTweakViewController
//
//  Created by Tanner on 8/31/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBNumberCell.h"


@implementation TBNumberCell

- (void)initSubviews {
    [super initSubviews];

    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
}

#pragma mark Public interface

- (void)setNumberType:(MKTypeEncoding)numberType {
    _numberType = numberType;
    
    if (numberType == MKTypeEncodingFloat || numberType == MKTypeEncodingDouble) {
        self.textField.placeholder = @"3.14159";
    } else if (numberType == MKTypeEncodingCBool || numberType == MKTypeEncodingChar) {
        self.textField.placeholder = @"true, false, yes, no";
    } else {
        self.textField.placeholder = @"1048576";
    }
}

#pragma mark UITextFieldDelegate overrides

- (BOOL)textField:(UITextField *)textField shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    static NSCharacterSet *disallowedCharacters = nil;
    static NSString *allowedChars = @"1234567890.truefalseyesnoTRUEFALSEYESNO";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        disallowedCharacters = [NSCharacterSet characterSetWithCharactersInString:allowedChars].invertedSet;
    });
    return [text rangeOfCharacterFromSet:disallowedCharacters].location == NSNotFound;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidEndEditing:textField];
    
    NSNumber *number = nil;
    if ([self.textField.text.lowercaseString hasPrefix:@"y"] ||
        [self.textField.text.lowercaseString hasPrefix:@"t"]) {
        number = @YES;
    } else {
        number = [NSNumber numberWithFloat:MAX(self.text.doubleValue, self.text.integerValue)];
    }
    
    self.delegate.coordinator.number = number;
}

@end
