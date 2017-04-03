//
//  TBConfigureHookViewController+Protocols.h
//  TBTweakViewController
//
//  Created by Tanner on 9/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBConfigureHookViewController.h"
#import "TBHookTypeSectionController.h"
#import "TBValueSectionController.h"
#import "TBArgValueHookSectionController.h"


@interface TBConfigureHookViewController (Protocols)
<TBHookTypeSectionDelegate, TBArgHookSectionDelegate>

- (void)initializeSectionControllers;
- (void)configureTableViewForCellReuseAndAutomaticRowHeight;

@end
