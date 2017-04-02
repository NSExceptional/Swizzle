//
//  TBKeyPathViewController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBTweak.h"


@interface TBKeyPathViewController : UIViewController

/// Callback executes after tweak has hook added to it.
+ (instancetype)forTweak:(TBTweak *)tweak callback:(void(^)())callback;

@end
