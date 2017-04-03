//
//  TBHookListViewController.h
//  TBTweakViewController
//
//  Created by Tanner on 4/2/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTweak.h"


@interface TBHookListViewController : UITableViewController

+ (instancetype)listForTweak:(TBTweak *)tweak isLocal:(BOOL)local;

@end
