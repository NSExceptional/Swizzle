//
//  TBDetailDisclosureCell.m
//  TBTweakViewController
//
//  Created by Tanner on 10/6/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBDetailDisclosureCell.h"
#import "Categories.h"


@implementation TBDetailDisclosureCell

+ (UITableViewCellStyle)defaultStyle {
    return UITableViewCellStyleValue1;
}

- (void)initSubviews {
    [super initSubviews];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    self.detailTextLabel.font = UIFont.codeFont;
}

@end
