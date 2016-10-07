//
//  TBSwitchCell.m
//  TBTweakViewController
//
//  Created by Tanner on 9/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBSwitchCell.h"


@implementation TBSwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        _switchh = [[UISwitch alloc] initWithFrame:CGRectZero];
        self.accessoryView = self.switchh;
        [self.switchh addTarget:self action:@selector(didToggleSwitch) forControlEvents:UIControlEventValueChanged];
        self.textLabel.numberOfLines = 1;
    }
    
    return self;
}

- (void)didToggleSwitch {
    if (self.switchToggleAction) {
        self.switchToggleAction(self.switchh.isOn);
    }
}

@end
