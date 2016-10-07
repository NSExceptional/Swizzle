//
//  TBTweakListViewController.h
//  TBTweakListViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


/// A table view list of all tweaks for the current app or the system.
@interface TBTweakListViewController : UITableViewController

+ (instancetype)appTweaks;
+ (instancetype)systemTweaks;

@end
