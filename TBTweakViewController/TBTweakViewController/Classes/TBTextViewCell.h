//
//  TBTextViewCell.h
//  TBTweakViewController
//
//  Created by Tanner on 3/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBBaseValueCell.h"
@class MASConstraintMaker;


#pragma mark - TBTextViewCell
@interface TBTextViewCell : TBBaseValueCell <UITextViewDelegate>

#pragma mark Public
@property (nonatomic) NSString *text;

#pragma mark Internal
@property (nonatomic, readonly) UITextView *textView;

- (void)updateConstraints:(MASConstraintMaker *)make;

@end
