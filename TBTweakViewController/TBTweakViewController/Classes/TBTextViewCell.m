//
//  TBTextViewCell.m
//  TBTweakViewController
//
//  Created by Tanner on 3/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBTextViewCell.h"
#import "Masonry.h"


@implementation TBTextViewCell

- (void)initSubviews {
    _textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
    self.textView.text     = @"";
    self.textView.delegate = self;
    self.textView.font     = self.textLabel.font;
    self.textView.scrollEnabled      = NO;
    self.textView.textContainerInset = UIEdgeInsetsMake(4, 16, 0, 0);

    self.textView.autocorrectionType     = UITextAutocorrectionTypeNo;
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;

    [self.contentView addSubview:self.textView];
}

- (void)updateConstraints {
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        [self updateConstraints:make];
    }];

    [super updateConstraints];
}

- (void)updateConstraints:(MASConstraintMaker *)make {
    make.edges.equalTo(self.contentView);
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

- (BOOL)textView:(UITextView *)tv shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.delegate.currentResponder = nil;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.delegate textViewDidChange:textView cell:self];
}

@end
