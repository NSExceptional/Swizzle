//
//  TBSwitchCell.h
//  TBTweakViewController
//
//  Created by Tanner on 9/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBTableViewCell.h"


@interface TBSwitchCell : TBTableViewCell

@property (nonatomic, readonly) UISwitch *switchh;
@property (nonatomic, copy) void (^switchToggleAction)(BOOL on);

@end
