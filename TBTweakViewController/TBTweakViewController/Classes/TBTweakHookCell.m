//
//  TBTweakHookCell.m
//  TBTweakViewController
//
//  Created by Tanner on 8/22/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBTweakHookCell.h"
#import "UIFont+Swizzle.h"


@implementation TBTweakHookCell

- (void)initSubviews {
    [super initSubviews];
    self.textLabel.font = [UIFont codeFont];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setHookType:(TBHookType)hookType {
    if (_hookType == hookType) return;
    
    _hookType = hookType;
    switch (hookType) {
        case TBHookTypeUnspecified:
            self.detailTextLabel.text = @"ERROR: INCOMPLETE TWEAK";
            break;
        case TBHookTypeChirpCode: {
            self.detailTextLabel.text = @"Re-implements the method in Chirp";
            break;
        }
        default: {
            if (self.hookType & TBHookTypeReturnValue) {
                if (self.hookType & TBHookTypeArguments) {
                    self.detailTextLabel.text = @"Overrides return value and arguments";
                }
                self.detailTextLabel.text = @"Overrides return value";
            }
            if (self.hookType & TBHookTypeArguments) {
                self.detailTextLabel.text = @"Overrides argument value(s)";
            }
        }
    }
}

@end
