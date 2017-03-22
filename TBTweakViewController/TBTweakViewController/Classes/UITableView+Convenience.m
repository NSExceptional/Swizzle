//
//  UITableView+Convenience.m
//  TBTweakViewController
//
//  Created by Tanner on 3/9/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "UITableView+Convenience.h"
#import "TBBaseValueCell.h"

@implementation UITableView (Convenience)

- (void)registerCell:(Class)cellClass {
    [self registerClass:cellClass forCellReuseIdentifier:[cellClass reuseID]];
}

- (void)registerCells:(NSArray<Class> *)classes {
    for (Class cls in classes) {
        [self registerClass:cls forCellReuseIdentifier:[cls reuseID]];
    }
}


- (void)reloadSection:(NSUInteger)section {
    [self reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation {
    [self reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
}

@end
