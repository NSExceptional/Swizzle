//
//  TBKeyPathSearchController.h
//  TBTweakViewController
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TBKeyPathSearchControllerDelegate <NSObject>
@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) UISearchBar *searchBar;
@property (nonatomic, readonly) UINavigationController *navigationController;
@end

@interface TBKeyPathSearchController : NSObject <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

+ (instancetype)delegate:(id<TBKeyPathSearchControllerDelegate>)delegate;

@end
