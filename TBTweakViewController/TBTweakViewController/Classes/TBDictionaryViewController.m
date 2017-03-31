//
//  TBDictionaryViewController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/31/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBDictionaryViewController.h"
#import "TBAddElementSectionController.h"
#import "UITableView+Convenience.h"


@interface TBDictionaryViewController ()
@property (nonatomic, readonly) NSMutableDictionary *dictionary;
@end

#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation TBDictionaryViewController

- (NSMutableDictionary *)dictionary {
    return self.storage;
}

- (void)setDictionary:(NSMutableDictionary *)dictionary {
    self.storage = dictionary;
}

- (void)setStorage:(id)storage {
    if ([storage isKindOfClass:[NSMutableDictionary class]]) {
        super.storage = storage;
    } else if ([storage isKindOfClass:[NSDictionary class]]) {
        super.storage = [storage mutableCopy];
    } else {
        @throw NSGenericException;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.dictionary) {
        self.dictionary = [NSMutableDictionary dictionary];
    }

    [self reloadSectionControllers];
}

- (void)reloadSectionControllers {
    [self.dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        [self.sections addObject:[TBDictionaryEntrySectionController delegate:self key:key value:value]];
    }];

    [self.sections addObject:[TBAddElementSectionController delegate:self onTap:^{
        TBSectionController *section = [TBDictionaryEntrySectionController delegate:self];
        [self.sections insertObject:section atIndex:self.sections.count-2];
        [self.tableView insertSection:self.sections.count-2];
        [self.tableView deselectSelectedRow];
    }]];
}

- (void)prepareStorageForReturn {
    for (TBDictionaryEntrySectionController *section in self.sections) {
        self.dictionary[section.key] = section.value;
    }
}

@end
