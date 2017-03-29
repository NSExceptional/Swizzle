//
//  UITableView+FUCK.m
//  TBTweakViewController
//
//  Created by Tanner on 3/29/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "UITableView+FUCK.h"

@implementation UITableView (FUCK)

- (UIView *)fuckingHeaderView {
    return self.tableHeaderView;
}

- (void)setFuckingHeaderView:(UIView *)headerView {
    headerView.frame = ({
        CGRect f = headerView.frame;
        f.size.width = self.frame.size.width;
        f;
    });

    [headerView setNeedsLayout];
    [headerView layoutIfNeeded];
    CGFloat height = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    headerView.frame = ({
        CGRect f = headerView.frame;
        f.size.height = height;
        f;
    });

    self.tableHeaderView = headerView;
}

@end
