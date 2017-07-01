//
//  TBTweakManager.h
//  TBTweakViewController
//
//  Created by Tanner on 8/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTweak.h"


@interface TBTweakManager : NSObject <UITableViewDelegate, UITableViewDataSource>

+ (instancetype)sharedManager;

- (void)addTweak:(TBTweak *)tweak;
- (void)addAppTweak:(TBTweak *)tweak;
- (void)addSystemTweak:(TBTweak *)tweak;

/// Used to make adding tweaks from two different sources easier.
@property (nonatomic) BOOL nextTweakIsSystemTweak;

@property (nonatomic) UITableViewController *appTweaksTableViewController;
@property (nonatomic) UITableViewController *systemTweaksTableViewController;

- (void)saveAppTweaks;
- (void)saveSystemTweaks;
- (void)rootViewDidDismiss;

@property (nonatomic) BOOL appTweakDelta;
@property (nonatomic) BOOL systemTweakDelta;

@end
