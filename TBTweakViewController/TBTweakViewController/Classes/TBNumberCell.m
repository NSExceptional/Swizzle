//
//  TBNumberCell.m
//  TBTweakViewController
//
//  Created by Tanner on 8/31/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBNumberCell.h"
#import "Masonry.h"


@interface TBNumberCell () <UITextFieldDelegate>
@property (nonatomic) UITextField *textField;
@end

@implementation TBNumberCell

- (void)initSubviews {
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    _textField.text = @"";
    self.textField.delegate = self;
    self.textField.autocorrectionType     = UITextAutocorrectionTypeNo;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
    
    [self.contentView addSubview:self.textField];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).with.insets(UIEdgeInsetsMake(11, 16, 11, 0));
    }];
}

#pragma mark Public interface

- (NSString *)text {
    return self.textField.text;
}

- (void)setText:(NSString *)text {
    self.textField.text = text;
    [self setNeedsUpdateConstraints];
}

- (void)setNumberType:(MKTypeEncoding)numberType {
    _numberType = numberType;
    
    if (numberType == MKTypeEncodingFloat || numberType == MKTypeEncodingDouble) {
        self.textField.placeholder = @"3.14159";
    } else if (numberType == MKTypeEncodingCBool || numberType == MKTypeEncodingChar) {
        self.textField.placeholder = @"true, false, yes, no";
    } else {
        self.textField.placeholder = @"1, 5, 1024";
    }
}

#pragma mark UItextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.delegate.currentResponder = textField;
}

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
    NSNumber *number = nil;
    if ([self.textField.text.lowercaseString hasPrefix:@"y"] ||
        [self.textField.text.lowercaseString hasPrefix:@"t"]) {
        number = @YES;
    } else {
        number = [NSNumber numberWithFloat:MAX(self.text.floatValue, self.text.integerValue)];
    }
    
    self.delegate.number = number;
    self.delegate.currentResponder = nil;
}

@end
