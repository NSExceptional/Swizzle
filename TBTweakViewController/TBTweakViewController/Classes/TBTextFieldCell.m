//
//  TBTextFieldCell.m
//  TBTweakViewController
//
//  Created by Tanner on 3/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBTextFieldCell.h"
#import "Masonry/Masonry.h"


@implementation TBTextFieldCell

#pragma mark Overrides

- (void)initSubviews {
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    _textField.text = @"";
    self.textField.delegate = self;
    self.textField.autocorrectionType     = UITextAutocorrectionTypeNo;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.keyboardType           = UIKeyboardTypeAlphabet;
    self.textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

    [self.contentView addSubview:self.textField];
}

- (void)updateConstraints {
    [super updateConstraints];

    [self.textField mas__remakeConstraints:^(SWZConstraintMaker *make) {
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


#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.delegate.currentResponder = textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.delegate.currentResponder = nil;
    [self.delegate didUpdateValue:textField.text];
}

@end
