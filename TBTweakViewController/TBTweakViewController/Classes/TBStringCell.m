//
//  TBStringCell.m
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBStringCell.h"
#import "Masonry.h"


@interface TBStringCell () <UITextViewDelegate>
@property (nonatomic) UITextView *textView;
@end

@implementation TBStringCell

- (void)initSubviews {
    _textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
    _textView.text = @"";
    self.textView.delegate = self;
    self.textView.font     = self.textLabel.font;
    self.textView.textContainerInset = UIEdgeInsetsMake(4, 16, 0, 0);
    
    self.textView.autocorrectionType     = UITextAutocorrectionTypeNo;
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [self.contentView addSubview:self.textView];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

#pragma mark Public interface

- (NSString *)text {
    return self.textView.text;
}

- (void)setText:(NSString *)text {
    self.textView.text = text;
    [self setNeedsUpdateConstraints];
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.delegate.currentResponder = textView;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    static NSCharacterSet *disallowedCharacters = nil;
    static NSString *allowedChars = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 ,()[]+-=/.$!{}";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        disallowedCharacters = [NSCharacterSet characterSetWithCharactersInString:allowedChars].invertedSet;
    });
    return [text rangeOfCharacterFromSet:disallowedCharacters].location == NSNotFound;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.delegate.string = textView.text;
    self.delegate.currentResponder = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.delegate textViewDidChange:textView cell:self];
}

@end
