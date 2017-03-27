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

    self.title = @"Create Tweak";

    // Search bar stuff
    _searchController          = [TBKeyPathSearchController delegate:self];
    self.searchBar.delegate    = self.searchController;
    self.searchBar.placeholder = @"UIKit*.UIView.-setFrame:";
    self.tableView.tableHeaderView = self.searchBar;

    // Cancel button
    id cancel = [UIBarButtonItem item:UIBBItemCancel target:self.navigationController action:@selector(dismissAnimated)];
    self.navigationItem.leftBarButtonItem = cancel;

    // Table view stuff
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerCell:[TBCodeFontCell class]];

    // Long press gesture for classes
    [self.tableView addGestureRecognizer:[UILongPressGestureRecognizer action:^(UIGestureRecognizer *gesture) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            NSIndexPath *ip = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:ip];
            [self.searchController longPressedRect:cell.frame at:ip];
        }
    }]];
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

#pragma mark Long press action

- (void)didSelectSuperclass:(UIMenuItem *)item {
    [self.searchController didSelectKeyPathOption:item.title];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return action == @selector(didSelectSuperclass:);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end
