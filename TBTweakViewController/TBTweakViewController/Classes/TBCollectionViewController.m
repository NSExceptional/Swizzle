//
//  TBCollectionViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/31/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBCollectionViewController.h"
#import "TBElementSectionController.h"
#import "TBAddElementSectionController.h"
#import "UITableView+Convenience.h"


@interface TBCollectionViewController ()
@property (nonatomic, readonly) id<Collection> collection;
@property (nonatomic, readonly) BOOL isOrdered;
@end

#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation TBCollectionViewController

+ (instancetype)withCompletion:(void(^)(id<Collection> result))completion
                          initialValue:(TBValue *)value {
    TBCollectionViewController *controller = [super withCompletion:(id)completion initialValue:value.value];
    controller.title = TBStringFromValueType(value.type);
    controller->_isOrdered = [controller.storage respondsToSelector:@selector(objectAtIndex:)];
    return controller;
}

- (id<Collection>)collection {
    return self.storage;
}

- (void)setCollection:(id<Collection>)collection {
    self.storage = collection;
}

- (void)setStorage:(id)storage {
    super.storage = [storage mutableCopy];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.collection) {
        @throw NSInternalInconsistencyException;
    } else {
        
    }

    [self reloadSectionControllers];
}

- (void)reloadSectionControllers {
    for (id object in self.collection) {
        [self.sections addObject:[TBElementSectionController delegate:self object:object]];
    }

    [self.sections addObject:[TBAddElementSectionController delegate:self onTap:^{
        TBSectionController *section = [TBElementSectionController delegate:self];
        [self.sections insertObject:section atIndex:self.sections.count-1];
        [self.tableView insertSection:self.sections.count-2];
        [self.tableView deselectSelectedRow];
    }]];
}

- (void)prepareStorageForReturn {
    [self.storage removeAllObjects];
    
    id last = self.sections.lastObject;
    id null = [NSNull null];
    [(id)self.sections enumerateObjectsUsingBlock:^(TBElementSectionController *section, NSUInteger idx, BOOL *stop) {
        if (section != last) {
            [self.storage addObject:section.coordinator.object ?: null];
        }
    }];
}

#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.isOrdered && section != self.sections.count-1) {
        return [NSString stringWithFormat:@"Element %ld", (long)section];
    }

    return nil;
}

@end
