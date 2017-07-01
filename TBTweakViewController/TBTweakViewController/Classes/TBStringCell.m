//
//  TBStringCell.m
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBStringCell.h"
#import "Masonry/Masonry.h"


@implementation TBStringCell

#pragma mark UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    [super textViewDidEndEditing:textView];
    [self.delegate didUpdateValue:textView.text];
}

@end
