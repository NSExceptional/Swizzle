//
//  TBChirpCell.m
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBChirpCell.h"
#import "Categories.h"
#import "Masonry/Masonry.h"


@implementation TBChirpCell

- (void)initSubviews {
    [super initSubviews];
    self.textView.font = UIFont.codeFont;
}

- (void)updateConstraints:(MASConstraintMaker *)make {
    [super updateConstraints:make];
    make.height.greaterThanOrEqualTo(@120);
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    static NSCharacterSet *disallowedCharacters = nil;
    static NSString *allowedChars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 ,()[]+-=/.$!{}";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        disallowedCharacters = [NSCharacterSet characterSetWithCharactersInString:allowedChars].invertedSet;
    });
    return [text rangeOfCharacterFromSet:disallowedCharacters].location == NSNotFound;
}

@end
