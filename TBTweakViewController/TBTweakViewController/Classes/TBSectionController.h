//
//  TBSectionController.h
//  TBTweakViewController
//
//  Created by Tanner on 10/9/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

@import UIKit;
@class TBValue, TBTableViewCell;


#pragma mark - TBSectionControllerDelegate
@protocol TBSectionControllerDelegate <NSObject>

- (void)reloadSectionControllers;
- (void)setArgumentHookValue:(TBValue *)value atIndex:(NSUInteger)idx;

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) UINavigationController *navigationController;

@end

#pragma mark - TBSectionController
@interface TBSectionController : NSObject

#pragma mark Public
+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate;

@property (nonatomic, readonly) NSUInteger sectionRowCount;
@property (nonatomic) UIResponder *currentResponder;

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (TBTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark Internal
@property (nonatomic, readonly) id<TBSectionControllerDelegate> delegate;

@end
