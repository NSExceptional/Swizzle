//
//  UITableView+TextViewResizing.m
//  TBTweakViewController
//
//  Created by Tanner on 3/31/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "UITableView+TextViewResizing.h"


@implementation UITableView (TextViewResizing)

- (void)textViewDidChange:(UITextView *)textView cell:(UITableViewCell *)cell {
#warning FIXME
    [self beginUpdates];
    [self endUpdates];

    CGSize size = textView.bounds.size;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)];

    // Update cell size only when cell's size is changed
    if (size.height != newSize.height) {
        [UIView setAnimationsEnabled:NO];
        [self beginUpdates];
        [self endUpdates];
        [UIView setAnimationsEnabled:YES];

        NSIndexPath *ip = [self indexPathForCell:cell];
        [self scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

@end
