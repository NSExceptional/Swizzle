//
//  TBMethodPickerViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 8/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBMethodPickerViewController.h"
#import "TBConfigureTweakViewController.h"
#import "TBTweak.h"
#import "TBTweakManager.h"

#import "MKMethod.h"
#import "NSObject+Reflection.h"


NSString * const kMethodCellReuse = @"kMethodCellReuse";

@interface TBMethodPickerViewController () <UISearchBarDelegate>
@property (nonatomic, readonly) NSArray<MKMethod*> *methods;
@property (nonatomic          ) NSArray<MKMethod*> *filteredMethods;
@property (nonatomic, readonly) NSArray<NSString*> *superclasses;
@property (nonatomic, readonly) UISearchBar *searchBar;
@property (nonatomic, readonly) Class targetClass;

@end

@implementation TBMethodPickerViewController

+ (instancetype)pickMethodFromClass:(Class)cls {
    TBMethodPickerViewController *picker = [self new];
    picker->_targetClass = cls;
    picker->_methods     = [[cls allMethods] sortedArrayUsingSelector:@selector(compare:)];
    Class baseClass      = cls;
    
    // Find superclasses
    NSMutableArray *superclasses = [NSMutableArray array];
    while ([baseClass superclass]) {
        [superclasses addObject:NSStringFromClass([baseClass superclass])];
        baseClass = [baseClass superclass];
    }
    picker->_superclasses = [superclasses sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return picker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.title = @"Methods";
    self.navigationItem.prompt = @"Choose a method to hook, or view a superclass.";
    
    self.filteredMethods = self.methods;
    
    // Search bar stuff
    _searchBar                 = [UISearchBar new];
    self.searchBar.delegate    = self;
    self.searchBar.placeholder = @"Filter";
    [self.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchBar;
    
    // Table view stuff
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMethodCellReuse];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kMethodCellReuse forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 1;
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = self.superclasses[indexPath.row];
            break;
        case 1:
            cell.textLabel.text = self.filteredMethods[indexPath.row].description;
            break;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.superclasses.count;
        case 1:
            return self.filteredMethods.count;
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.superclasses.count ? 2 : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Superclasses";
        case 1:
            return @"Methods";
        default:
            return 0;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            // View methods of superclass
            Class cls = NSClassFromString(self.superclasses[indexPath.row]);
            TBMethodPickerViewController *methodPicker = [TBMethodPickerViewController pickMethodFromClass:cls];
            [self.navigationController pushViewController:methodPicker animated:YES];
            break;
        }
        case 1: {
            // Hook method
            MKMethod *method   = self.filteredMethods[indexPath.row];
            TBMethodHook *hook = [TBMethodHook target:self.targetClass action:method.selector isClassMethod:!method.isInstanceMethod];
            TBTweak *tweak     = [TBTweak tweakWithHook:hook];
            TBConfigureTweakViewController *config = [TBConfigureTweakViewController forTweak:tweak saveAction:^{
                [[TBTweakManager sharedManager] addTweak:tweak];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [self.navigationController pushViewController:config animated:YES];
            break;
        }
    }
}

#pragma mark - Filtering

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length) {
        NSPredicate *searchPreidcate = [NSPredicate predicateWithBlock:^BOOL(MKMethod *method, NSDictionary *bindings) {
            BOOL matches = NO;
            if ([method.description rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0) {
                matches = YES;
            }
            return matches;
        }];
        self.filteredMethods = [self.methods filteredArrayUsingPredicate:searchPreidcate];
    } else {
        self.filteredMethods = self.methods;
    }
    
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

@end
