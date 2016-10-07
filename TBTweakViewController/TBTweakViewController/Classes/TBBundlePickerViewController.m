//
//  TBBundlePickerViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 8/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBBundlePickerViewController.h"
#import "TBClassPickerViewController.h"
#import "TBMethodPickerViewController.h"
#import "UIViewController+Dismissal.h"
#import <objc/runtime.h>


static NSMutableDictionary<NSString*,NSString*> *longNamesToShortNames;
@interface TBBundlePickerViewController () <UISearchBarDelegate>

@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, strong) NSArray *filteredImageNames;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) Class foundClass;

@end

@implementation TBBundlePickerViewController

+ (void)initialize {
    if (self == [self class]) {
        longNamesToShortNames = [NSMutableDictionary dictionary];
    }
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [self loadImageNames];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Loaded Bundles";
    self.navigationItem.prompt = @"Choose a bundle to see its classes.";
    
    // Search bar stuff
    self.searchBar             = [UISearchBar new];
    self.searchBar.delegate    = self;
    self.searchBar.placeholder = @"Filter";
    [self.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchBar;
    
    // Cancel button
    id cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                              target:self.navigationController action:@selector(dismissAnimated)];
    self.navigationItem.leftBarButtonItem = cancel;
    
    // Table view stuff
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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

#pragma mark - Binary Images

- (void)loadImageNames {
    unsigned int imageNamesCount = 0;
    const char **imageNames      = objc_copyImageNames(&imageNamesCount);
    
    if (imageNames) {
        NSMutableArray *imageNameStrings = [NSMutableArray array];
        for (unsigned int i = 0; i < imageNamesCount; i++) {
            [imageNameStrings addObject:@(imageNames[i])];
        }
        
        free(imageNames);
        
        // Sort alphabetically
        self.imageNames = [imageNameStrings sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(NSString *name1, NSString *name2) {
            NSString *shortName1 = [self shortNameForImageName:name1];
            NSString *shortName2 = [self shortNameForImageName:name2];
            return [shortName1 caseInsensitiveCompare:shortName2];
        }];
    }
}

- (NSString *)shortNameForImageName:(NSString *)imageName {
    // Cache
    NSString *shortName = longNamesToShortNames[imageName];
    if (shortName) {
        return shortName;
    }
    
    NSArray *components = [imageName componentsSeparatedByString:@"/"];
    if (components.count >= 2) {
        NSString *parentDir = components[components.count - 2];
        if ([parentDir hasSuffix:@".framework"]) {
            shortName = parentDir;
        }
    }
    
    if (!shortName) {
        shortName = imageName.lastPathComponent;
    }
    
    longNamesToShortNames[imageName] = shortName;
    return shortName;
}

- (void)setImageNames:(NSArray *)imageNames {
    if (![_imageNames isEqual:imageNames]) {
        _imageNames = imageNames;
        self.filteredImageNames = imageNames;
    }
}

#pragma mark - Filtering

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length) {
        NSPredicate *searchPreidcate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            BOOL matches = NO;
            NSString *shortName = [self shortNameForImageName:evaluatedObject];
            if ([shortName rangeOfString:searchText options:NSCaseInsensitiveSearch].length > 0) {
                matches = YES;
            }
            return matches;
        }];
        self.filteredImageNames = [self.imageNames filteredArrayUsingPredicate:searchPreidcate];
    } else {
        self.filteredImageNames = self.imageNames;
    }
    
    self.foundClass = NSClassFromString(searchText);
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredImageNames.count + (self.foundClass ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = 1;
    }
    
    NSString *executablePath;
    if (self.foundClass) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"Class \"%@\"", self.searchBar.text];
            return cell;
        } else {
            executablePath = self.filteredImageNames[indexPath.row-1];
        }
    } else {
        executablePath = self.filteredImageNames[indexPath.row];
    }
    
    cell.textLabel.text = [self shortNameForImageName:executablePath];
    return cell;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && self.foundClass) {
        TBMethodPickerViewController *methodPicker = [TBMethodPickerViewController pickMethodFromClass:self.foundClass];
        [self.navigationController pushViewController:methodPicker animated:YES];
    } else {
        NSString *bundleName = self.filteredImageNames[self.foundClass ? indexPath.row-1 : indexPath.row];
        TBClassPickerViewController *classPicker = [TBClassPickerViewController pickFromBinaryImageWithName:bundleName];
        [self.navigationController pushViewController:classPicker animated:YES];
    }
}

@end
