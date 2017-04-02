//
//  TBTweakHookCell.h
//  TBTweakViewController
//
//  Created by Tanner on 8/22/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBSwitchCell.h"
#import "TBTweak.h"


@interface TBTweakHookCell : TBSwitchCell

/// Chances the detail text of the cell
@property (nonatomic) TBHookType hookType;

@end
