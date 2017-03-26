//
//  TBClassPickerViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 8/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBClassPickerViewController.h"
#import "TBMethodPickerViewController.h"
#import <objc/runtime.h>


@interface TBClassPickerViewController () <UISearchBarDelegate>
@property (nonatomic, copy) NSString *binaryImageName;
@property (nonatomic) NSArray *classNames;
@property (nonatomic) NSArray *filteredClassNames;
@property (nonatomic) UISearchBar *searchBar;
@end

@implementation TBClassPickerViewController

+ (instancetype)pickFromBinaryImageWithName:(NSString *)bundleName {
    TBClassPickerViewController *picker = [self new];
    picker.binaryImageName = bundleName;
    return picker;
}

+ (instancetype)pickSuperclassesOf:(Class)baseClass {
    TBClassPickerViewController *picker = [self new];
    
    NSMutableArray *superclasses = [NSMutableArray array];
    while ([baseClass superclass]) {
        [superclasses addObject:NSStringFromClass([baseClass superclass])];
        baseClass = [baseClass superclass];
    }
    picker.classNames = [superclasses sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    return picker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.prompt = @"Choose a class to see its methods.";
    
    self.searchBar             = [UISearchBar new];
    self.searchBar.placeholder = @"Filter";
    self.searchBar.delegate    = self;
    [self.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchBar;

    // Table view stuff
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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

- (void)setBinaryImageName:(NSString *)binaryImageName {
    if (![_binaryImageName isEqual:binaryImageName]) {
        _binaryImageName = binaryImageName;
        [self loadClassNames];
        //        [self updateTitle];
    }
}

- (void)setClassNames:(NSArray *)classNames {
    _classNames = classNames;
    self.filteredClassNames = classNames;
}

- (void)loadClassNames {
    unsigned int classNamesCount = 0;
    const char **classNames = objc_copyClassNamesForImage([self.binaryImageName UTF8String], &classNamesCount);
    if (classNames) {
        NSMutableArray *classNameStrings = [NSMutableArray array];
        for (unsigned int i = 0; i < classNamesCount; i++) {
            const char *className = classNames[i];
            NSString *classNameString = [NSString stringWithUTF8String:className];
            [classNameStrings addObject:classNameString];
        }
        
        self.classNames = [classNameStrings sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        free(classNames);
    }
}

- (void)updateTitle {
    NSString *shortImageName = self.binaryImageName.lastPathComponent;
    if (shortImageName.length < 10) {
        self.title = [NSString stringWithFormat:@"%@ Classes (%lu)", shortImageName, (unsigned long)[self.filteredClassNames count]];
    } else {
        self.title = @"Classes";
    }
}

#pragma mark - Search

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length) {
        NSPredicate *searchPreidcate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", searchText];
        self.filteredClassNames = ({
            NSArray *tmp = [self.classNames filteredArrayUsingPredicate:searchPreidcate];
            // Put results with the prefix at the top
            tmp = [tmp sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString* obj2) {
                if ([obj1.lowercaseString hasPrefix:searchText]) {
                    if ([obj2.lowercaseString hasPrefix:searchText]) {
                        return [obj1 compare:obj2];
                    }
                    
                    return NSOrderedDescending;
                }
                else if ([obj2.lowercaseString hasPrefix:searchText]) {
                    return NSOrderedAscending;
                }
                
                return [obj1 compare:obj2];
            }];
        });
        
    } else {
        self.filteredClassNames = self.classNames;
    }
    [self updateTitle];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredClassNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = 1;
        //        cell.textLabel.font = [UIFont systemFontOfSize:12];
    }
    
    cell.textLabel.text = self.filteredClassNames[indexPath.row];
    
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cls = NSClassFromString(self.filteredClassNames[indexPath.row]);
    TBMethodPickerViewController *methodPicker = [TBMethodPickerViewController pickMethodFromClass:cls];
    [self.navigationController pushViewController:methodPicker animated:YES];
}

@end
