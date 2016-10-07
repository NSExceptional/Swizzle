//
//  TBMethodPickerViewController.h
//  TBTweakViewController
//
//  Created by Tanner on 8/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TBMethodPickerViewController : UITableViewController

+ (instancetype)pickMethodFromClass:(Class)cls;

@end
