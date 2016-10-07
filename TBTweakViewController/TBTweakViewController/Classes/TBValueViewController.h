//
//  TBValueViewController.h
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBValue.h"
#import "MirrorKit-Constants.h"


@interface TBValueViewController : UITableViewController

+ (instancetype)withSaveAction:(void(^)(TBValue *value))saveAction
                         title:(NSString *)title
                  initialValue:(TBValue *)value
              isPartOfOverride:(BOOL)isOverride
                          type:(MKTypeEncoding)type;

@property (nonatomic) NSMutableArray<TBValue*> *collecitonValues;
@property (nonatomic) NSMutableArray<TBValue*> *collecitonKeys;

@end
