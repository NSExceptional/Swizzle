//
//  TBObjectCreationViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/31/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBObjectCreationViewController.h"
#import "Categories.h"
#import "TBBaseValueCell.h"


@interface TBObjectCreationViewController ()
@property (nonatomic, readonly) void (^completion)(id);
@end

#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation TBObjectCreationViewController
@dynamic navigationController;

+ (instancetype)withCompletion:(void (^)(id))completion {
    TBObjectCreationViewController *controller = [self title:nil configuration:^(UINavigationItem *item, id vc) {
        item.rightBarButtonItem = [UIBarButtonItem item:UIBBItemSave target:vc action:@selector(done)];
    }];
    controller->_completion = completion;
    controller->_sections   = [NSMutableArray array];
    return controller;
}

+ (instancetype)withCompletion:(void(^)(id object))completion initialValue:(id)value {
    TBObjectCreationViewController *controller = [self withCompletion:completion];
    controller.storage = value;
    return controller;
}

- (id)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Row height
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerCells:TBBaseValueCell.allValueCells];
}

#pragma mark Private

- (void)editorsResignFirstResponder {
    for (TBSectionController *section in self.sections) {
        [section.currentResponder resignFirstResponder];
    }
}

- (void)done {
    [self editorsResignFirstResponder];
    [self prepareStorageForReturn];
    self.completion(self.storage);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TBSectionControllerDelegate

- (void)reloadSectionControllers { }

- (void)removeSection:(TBSectionController *)section {
    NSUInteger idx = [self.sections indexOfObject:section];
    if (idx != NSNotFound) {
        [self.sections removeObjectAtIndex:idx];
        [self.tableView deleteSection:idx];
    }
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.sections[indexPath.section] cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].sectionRowCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

#pragma mark UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self editorsResignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.sections[indexPath.section] didSelectRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.sections[indexPath.section] shouldHighlightRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

@end
