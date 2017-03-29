//
//  TBColorCell.m
//  TBTweakViewController
//
//  Created by Tanner on 8/31/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBColorCell.h"

@implementation TBColorCell

- (void)initSubviews {
    [super initSubviews];

    self.textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
}

#pragma mark UITextFieldDelegate overrides

- (BOOL)textField:(UITextField *)textField shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    static NSCharacterSet *disallowedCharacters = nil;
    static NSString *allowedChars = @"1234567890ABCDEFabcdef";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        disallowedCharacters = [NSCharacterSet characterSetWithCharactersInString:allowedChars].invertedSet;
    });

    if ([text rangeOfCharacterFromSet:disallowedCharacters].location == NSNotFound) {
        // New text must be 6 digits or less
        return [textField.text stringByReplacingCharactersInRange:range withString:text].length < 7;
    }

    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidEndEditing:textField];

    // Pad with trailing zeroes as needed
    NSUInteger len = self.textField.text.length;
    if (len < 6) {
        NSMutableString *string = self.textField.text.mutableCopy;
        for (NSUInteger i = 0; i < 6 - len; i++) {
            [string appendString:@"0"];
        }

        self.textField.text = string;
    }
}

@end
