//
//  TBTypePickerViewController.h
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBValue.h"
#import "MirrorKit-Constants.h"


@interface TBTypePickerViewController : UITableViewController

+ (instancetype)withCompletion:(void(^)(TBValueType newType))completion
                         title:(NSString *)title
                          type:(MKTypeEncoding)type
                       current:(TBValueType)current;

@end
