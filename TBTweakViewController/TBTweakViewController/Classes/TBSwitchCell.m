//
//  TBSwitchCell.m
//  TBTweakViewController
//
//  Created by Tanner on 9/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBSwitchCell.h"


@implementation TBSwitchCell

- (void)initSubviews {
    _switchh = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.switchh addTarget:self action:@selector(didToggleSwitch) forControlEvents:UIControlEventValueChanged];

    self.accessoryView = self.switchh;
    self.textLabel.numberOfLines = 1;
}

- (void)didToggleSwitch {
    if (self.switchToggleAction) {
        self.switchToggleAction(self.switchh.isOn);
    }
}

@end
