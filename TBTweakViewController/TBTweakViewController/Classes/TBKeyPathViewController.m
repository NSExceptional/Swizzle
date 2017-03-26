//
//  TBKeyPathViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBKeyPathViewController.h"
#import "TBKeyPathSearchController.h"
#import "TBCodeFontCell.h"
#import "Categories.h"
#import <Masonry.h>


@interface TBKeyPathViewController () <TBKeyPathSearchControllerDelegate>

@property (nonatomic, readonly ) TBKeyPathSearchController *searchController;
@property (nonatomic, readonly ) UIView *promptView;
@property (nonatomic, readwrite) UITableView *tableView;
@property (nonatomic, readwrite) UISearchBar *searchBar;

@end

@implementation TBKeyPathViewController
@dynamic navigationController;

#pragma mark - Setup, view events

- (void)loadView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.searchBar = [UISearchBar new];
    self.view = self.tableView;
    [self.searchBar sizeToFit];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Search bar stuff
    _searchController          = [TBKeyPathSearchController delegate:self];
    self.searchBar.delegate    = self.searchController;
    self.searchBar.placeholder = @"UIKit.UIView.-setFrame:";
    self.tableView.tableHeaderView = self.searchBar;

    // Cancel button
    id cancel = [UIBarButtonItem item:UIBBItemCancel target:self.navigationController action:@selector(dismissAnimated)];
    self.navigationItem.leftBarButtonItem = cancel;

    // Table view stuff
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerCell:[TBCodeFontCell class]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    [self.searchBar becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

@end
