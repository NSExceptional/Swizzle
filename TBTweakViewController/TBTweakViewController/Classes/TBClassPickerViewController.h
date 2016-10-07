//
//  TBClassPickerViewController.h
//  TBTweakViewController
//
//  Created by Tanner on 8/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


/// Used to pick a class for creating a tweak.
@interface TBClassPickerViewController : UITableViewController

+ (instancetype)pickFromBinaryImageWithName:(NSString *)bundleName;
+ (instancetype)pickSuperclassesOf:(Class)baseClass;

@end
