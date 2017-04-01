//
//  TBConfigureTweakViewController+Protocols.h
//  TBTweakViewController
//
//  Created by Tanner on 9/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBConfigureTweakViewController.h"
#import "TBHookTypeSectionController.h"
#import "TBValueSectionController.h"
#import "TBArgValueHookSectionController.h"


@interface TBConfigureTweakViewController (Protocols)
<TBHookTypeSectionDelegate, TBArgHookSectionDelegate>

- (void)configureTableViewForCellReuseAndAutomaticRowHeight;

@end
