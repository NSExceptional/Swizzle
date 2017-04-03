//
//  UITableView+Convenience.h
//  TBTweakViewController
//
//  Created by Tanner on 3/9/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Convenience)

/// @param cellClass must be a TBTableViewCell subclass
- (void)registerCell:(Class)cellClass;

/// @param classes an array of TBTableViewCell subclasses
- (void)registerCells:(NSArray *)classes;

- (void)reloadSection:(NSUInteger)section;
- (void)reloadSection:(NSUInteger)section withRowAnimation:(UITableViewRowAnimation)animation;

- (void)insertSection:(NSUInteger)section;
- (void)deleteSection:(NSUInteger)section;

- (void)deselectSelectedRow;

- (void)deleteRow:(NSIndexPath *)indexPath;
- (void)deleteRow:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;
- (void)insertRow:(NSIndexPath *)indexPath;
- (void)insertRow:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

@end
