//
//  TBDictionaryViewController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/31/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBObjectCreationViewController.h"
#import "TBDictionaryEntrySectionController.h"


@interface TBDictionaryViewController : TBObjectCreationViewController

+ (instancetype)withCompletion:(void(^)(NSMutableDictionary *result))completion;
+ (instancetype)withCompletion:(void(^)(NSMutableDictionary *result))completion
                  initialValue:(NSDictionary *)value;

@end
