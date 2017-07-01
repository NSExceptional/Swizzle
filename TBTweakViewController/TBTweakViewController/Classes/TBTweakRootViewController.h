//
//  TBTweakRootViewController.h
//  TBTweakViewController
//
//  Created by Tanner on 8/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


/// The tab bar controller of the app. Has three tabs:
/// Local tweaks, system tweaks, and settings.
@interface TBTweakRootViewController : UITabBarController

+ (instancetype)dismissAction:(void(^)())dismissAction;

@end
