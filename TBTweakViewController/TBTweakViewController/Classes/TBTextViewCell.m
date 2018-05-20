//
//  TBTextViewCell.m
//  TBTweakViewController
//
//  Created by Tanner on 3/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBTextViewCell.h"
#import "TBTextEditorView.h"
#import "UITableView+TextViewResizing.h"
#import "Masonry/Masonry.h"


@implementation TBTextViewCell

- (void)initSubviews {
    _textView = [TBTextEditorView delegate:self font:self.textLabel.font];
    [self.contentView addSubview:self.textView];
}

- (void)updateConstraints {
    [self.textView mas__updateConstraints:^(SWZConstraintMaker *make) {
        [self updateConstraints:make];
    }];

    [super updateConstraints];
}

- (void)updateConstraints:(SWZConstraintMaker *)make {
    make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(13, 16, 13, 16));
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
    [self.delegate.tableView textViewDidChange:textView cell:self];
}

@end
