//
//  UITableView+TextViewResizing.h
//  TBTweakViewController
//
//  Created by Tanner on 3/31/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UITableView (TextViewResizing)

- (void)textViewDidChange:(UITextView *)textView cell:(UITableViewCell *)cell;

@end
