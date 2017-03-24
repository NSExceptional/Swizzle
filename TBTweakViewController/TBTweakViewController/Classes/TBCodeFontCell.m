//
//  TBCodeFontCell.m
//  TBTweakViewController
//
//  Created by Tanner on 3/24/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBCodeFontCell.h"
#import "UIFont+Swizzle.h"

@implementation TBCodeFontCell

- (void)initSubviews {
    self.textLabel.font = [UIFont codeFont];
    self.detailTextLabel.font = [UIFont smallCodeFont];
}

@end
