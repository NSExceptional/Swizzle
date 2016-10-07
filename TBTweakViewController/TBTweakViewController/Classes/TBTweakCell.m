//
//  TBTweakCell.m
//  TBTweakViewController
//
//  Created by Tanner on 8/22/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBTweakCell.h"


@implementation TBTweakCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont fontWithName:@"Menlo-Regular" size:17];
    }
    
    return self;
}

- (void)setTweakType:(TBTweakType)tweakType {
    if (_tweakType == tweakType) return;
    
    _tweakType = tweakType;
    switch (tweakType) {
        case TBTweakTypeUnspecified:
            self.detailTextLabel.text = @"ERROR: INCOMPLETE TWEAK";
            break;
        case TBTweakTypeChirpCode: {
            self.detailTextLabel.text = @"Re-implements the method in Chirp";
            break;
        }
        default: {
            if (self.tweakType & TBTweakTypeHookReturnValue) {
                if (self.tweakType & TBTweakTypeHookArguments) {
                    self.detailTextLabel.text = @"Overrides return value and arguments";
                }
                self.detailTextLabel.text = @"Overrides return value";
            }
            if (self.tweakType & TBTweakTypeHookArguments) {
                self.detailTextLabel.text = @"Overrides argument value(s)";
            }
        }
    }
}

@end
