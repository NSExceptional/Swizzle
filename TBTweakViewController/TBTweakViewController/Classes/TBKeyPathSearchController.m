//
//  TBKeyPathSearchController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBKeyPathSearchController.h"
#import "TBKeyPathTokenizer.h"
#import "TBRuntimeController.h"
#import "TBCodeFontCell.h"
#import "NSString+KeyPaths.h"
#import "Categories.h"

#import "TBConfigureTweakViewController.h"
#import "TBTweakManager.h"
#import "TBMethodHook.h"


@interface TBKeyPathSearchController ()
@property (nonatomic, readonly, weak) id<TBKeyPathSearchControllerDelegate> delegate;
@property (nonatomic, readonly) NSTimer *timer;
@property (nonatomic) NSArray<NSString*> *bundlesOrClasses;
@property (nonatomic) NSArray<MKMethod*> *methods;
@property (nonatomic) TBKeyPath *keyPath;
@end

@implementation TBKeyPathSearchController

+ (instancetype)delegate:(id<TBKeyPathSearchControllerDelegate>)delegate {
    TBKeyPathSearchController *controller = [self new];
    controller->_bundlesOrClasses = [TBRuntimeController allBundleNames];
    controller->_delegate         = delegate;
    delegate.tableView.delegate   = controller;
    delegate.tableView.dataSource = controller;
    delegate.searchBar.delegate   = controller;

    return controller;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating) {
        [self.delegate.searchBar resignFirstResponder];
    }
}

#pragma mark Long press on class cell

- (void)longPressedRect:(CGRect)rect at:(NSIndexPath *)indexPath {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    menuController.menuItems = [self menuItemsForRow:indexPath.row];
    if (menuController.menuItems) {
        [self.delegate.searchBar resignFirstResponder];
        [menuController setTargetRect:rect inView:self.delegate.tableView];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (NSArray *)menuItemsForRow:(NSUInteger)row {
    if (!self.keyPath.methodKey && self.keyPath.classKey) {
        Class baseClass = NSClassFromString(self.bundlesOrClasses[row]);

        // Find superclasses
        NSMutableArray<NSString*> *superclasses = [NSMutableArray array];
        while ([baseClass superclass]) {
            [superclasses addObject:NSStringFromClass([baseClass superclass])];
            baseClass = [baseClass superclass];
        }

        // Map to UIMenuItems, will delegate call into didSelectKeyPathOption:
        return [superclasses map:^id(NSString *cls) {
            NSString *sel = [self.delegate.longPressItemSELPrefix stringByAppendingString:cls];
            return [[UIMenuItem alloc] initWithTitle:cls action:NSSelectorFromString(sel)];
        }];
    }

    return nil;
}

#pragma mark Key path stuff

- (void)didSelectSuperclass:(NSString *)name {
    NSString *bundle = [TBRuntimeController shortBundleNameForClass:name];
    bundle = [bundle stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
    NSString *newText = [NSString stringWithFormat:@"%@.%@.", bundle, name];
    self.delegate.searchBar.text = newText;

    // Update list
    self.keyPath = [TBKeyPathTokenizer tokenizeString:newText];
    [self updateTable];
}

- (void)didSelectKeyPathOption:(NSString *)text {
    // Change "Bundle.fooba" to "Bundle.foobar."
    NSString *orig = self.delegate.searchBar.text;
    NSString *keyPath = [orig stringByReplacingLastKeyPathComponent:text];
    self.delegate.searchBar.text = keyPath;

    // Update list
    self.keyPath = [TBKeyPathTokenizer tokenizeString:keyPath];
    [self updateTable];
}

- (void)didSelectMethod:(MKMethod *)method {
    TBTweak *tweak = [TBTweak tweakWithHook:[TBMethodHook hook:method]];
    TBConfigureTweakViewController *config = [TBConfigureTweakViewController forTweak:tweak saveAction:^{
        [[TBTweakManager sharedManager] addTweak:tweak];
        [self.delegate.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];

    [self.delegate.navigationController pushViewController:config animated:YES];
}

#pragma mark - Filtering + UISearchBarDelegate

- (void)updateTable {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray *models = [TBRuntimeController dataForKeyPath:_keyPath];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (_keyPath.methodKey) {
                _bundlesOrClasses = nil;
                _methods = models;
            } else {
                _bundlesOrClasses = models;
                _methods = nil;
            }
            
            [self.delegate.tableView reloadData];
        });
    });
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // Check if character is even legal
    if (![TBKeyPathTokenizer allowedInKeyPath:text]) {
        return NO;
    }

    // Actually parse input
    @try {
        text = [searchBar.text stringByReplacingCharactersInRange:range withString:text] ?: text;
        self.keyPath = [TBKeyPathTokenizer tokenizeString:text];
    } @catch (id e) {
        return NO;
    }

    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_timer invalidate];

    // Schedule update timer
    if (searchText.length) {
        _timer = [NSTimer fireSecondsFromNow:0.15 block:^{
            [self updateTable];
        }];
    }
    // ... or remove all rows
    else {
        _bundlesOrClasses = [TBRuntimeController allBundleNames];
        _methods = nil;
        [self.delegate.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_timer invalidate];
    [searchBar resignFirstResponder];
    [self updateTable];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *models = (id)_bundlesOrClasses ?: (id)_methods;
    return models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [TBCodeFontCell dequeue:tableView indexPath:indexPath];
    if (self.bundlesOrClasses) {
        cell.accessoryType  = UITableViewCellAccessoryNone;
        cell.textLabel.text = self.bundlesOrClasses[indexPath.row];
        cell.detailTextLabel.text = nil;
    } else {
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = self.methods[indexPath.row].fullName;
        cell.detailTextLabel.text = self.methods[indexPath.row].selectorString;
    }

    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.contentOffset = CGPointMake(0, - self.delegate.searchBar.frame.size.height - 20);
    
    if (self.bundlesOrClasses) {
        [_timer invalidate]; // Still maybe need to refresh when method is selected
        [self didSelectKeyPathOption:self.bundlesOrClasses[indexPath.row]];
    } else {
        [self didSelectMethod:self.methods[indexPath.row]];
    }
}

@end
