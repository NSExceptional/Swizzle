//
//  TBAddValueCell.m
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBAddValueCell.h"
#import "Masonry/Masonry.h"


@interface TBAddValueCell ()
@property (nonatomic, readonly) UIButton *plusIcon;
@end

@implementation TBAddValueCell

- (void)initSubviews {
    _plusIcon = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.accessoryView  = self.plusIcon;
    self.textLabel.text = @"Add value";
    self.textLabel.textColor = self.plusIcon.tintColor;
}

+ (BOOL)requiresConstraintBasedLayout { return NO; }

@end
