//
//  TBObjectCreationViewController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/31/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBSectionController.h"


@interface TBObjectCreationViewController : UITableViewController <TBSectionControllerDelegate>

+ (instancetype)withCompletion:(void(^)(id object))completion;
+ (instancetype)withCompletion:(void(^)(id object))completion initialValue:(id)value;

// Internal
@property (nonatomic) id storage;
@property (nonatomic, readonly) NSMutableArray<TBSectionController*> *sections;

- (void)prepareStorageForReturn;

@end
