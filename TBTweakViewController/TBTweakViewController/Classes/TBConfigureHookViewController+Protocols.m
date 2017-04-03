//
//  TBConfigureHookViewController+Protocols.m
//  TBTweakViewController
//
//  Created by Tanner on 9/1/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBConfigureHookViewController+Protocols.h"
#import "TBSettings.h"
#import "TBValue+ValueHelpers.h"
#import "TBSwitchCell.h"
#import "TBValueCells.h"

#import "SectionControllers.h"
#import "Categories.h"


@interface TBConfigureHookViewController ()
@property (nonatomic, readonly) NSUInteger totalNumberOfSections;
@end

@implementation TBConfigureHookViewController (Protocols)

- (void)removeSection:(TBSectionController *)section {
    
}

#pragma mark Helper

- (NSUInteger)totalNumberOfSections {
    NSUInteger i = 1;
//    if (self.hookTypeSectionController.overrideReturnValue)
    if (self.hookType & TBHookTypeReturnValue)
        i++;
//    if (self.hookTypeSectionController.overrideArguments)
    if (self.hookType & TBHookTypeArguments)
        i += self.hook.method.numberOfArguments - 2;
    
    return i;
}

- (void)configureTableViewForCellReuseAndAutomaticRowHeight {
    [self.tableView registerCells:TBBaseValueCell.allValueCells];
    
    // Row height
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

 #pragma mark Controller delegate methods

- (void)setArgumentHookValue:(TBValue *)value atIndex:(NSUInteger)idx {
    self.hookedArguments[idx] = value;
}

- (NSUInteger)hookArgumentCount {
    if (TBSettings.expertMode) {
        return self.hook.method.numberOfArguments;
    }

    return self.hook.method.numberOfArguments - 2;
}

- (BOOL)canOverrideReturnValue {
    return self.hook.canOverrideReturnValue;
}

- (BOOL)canOverrideAllArgumentValues {
    return self.hook.canOverrideAllArgumentValues;
}

- (void)initializeSectionControllers {
    // Remove everything and start over, add tweak type back to array
    NSMutableArray *controllers = self.dynamicSectionControllers;
    [controllers removeAllObjects];
    [controllers addObject:self.hookTypeSectionController];

#warning FIXME the below code will clear all existing values when toggled even in Expert mode

    // Add chirp hook controller
    if (self.hookType & TBHookTypeChirpCode) {
        [controllers addObject:[TBReturnValueHookSectionController delegate:self]];
    }
    // Add return value hook controller
    if (self.hookType & TBHookTypeReturnValue) {
        NSMethodSignature *signature = self.hook.method.signature;
        const char *type = signature.methodReturnType;
        [controllers addObject:[TBReturnValueHookSectionController delegate:self type:type]];
    }
    // Add argument value hook controllers
    if (self.hookType & TBHookTypeArguments) {
        MKMethod *method = self.hook.method;
        for (NSUInteger i = 2; i < method.numberOfArguments; i++) {
            id controller = [TBArgValueHookSectionController delegate:self
                                                            signature:method.signature
                                                        argumentIndex:i];
            [controllers addObject:controller];
        }
    }
}

/// Refreshes the contents of self.dynamicSectionControllers and updates the table view's contents.
- (void)reloadSectionControllers {
    NSArray *orig = self.dynamicSectionControllers.copy;

    [self initializeSectionControllers];
    [self updateTableViewWithOriginalSections:orig newSections:self.dynamicSectionControllers];
}

/// Performs a "diff" on the table view given the original sections array and the new sections.
- (void)updateTableViewWithOriginalSections:(NSArray *)orig newSections:(NSArray *)current {
    NSAssert(orig.count >= 1 && current.count >= 1, @"Must include top section");

    Class hookWithChirp   = [TBChirpImpSectionController class];
    Class hookReturnValue = [TBReturnValueHookSectionController class];
    Class hookArgValue    = [TBArgValueHookSectionController class];

    BOOL origContainsChirp = NO, currContainsChirp = NO;
    BOOL origContainsReturn = NO, currContainsReturn = NO;
    BOOL origHasArgs = NO, currHasArgs = NO;

    for (id controller in orig) {
        if ([controller isKindOfClass:hookWithChirp]) {
            origContainsChirp = YES;
        } else if ([controller isKindOfClass:hookReturnValue]) {
            origContainsReturn = YES;
        } else if ([controller isKindOfClass:hookArgValue]) {
            origHasArgs = YES;
            break;
        }
    }
    for (id controller in current) {
        if ([controller isKindOfClass:hookWithChirp]) {
            currContainsChirp = YES;
        } else if ([controller isKindOfClass:hookReturnValue]) {
            currContainsReturn = YES;
        } else if ([controller isKindOfClass:hookArgValue]) {
            currHasArgs = YES;
            break;
        }
    }

    NSMutableIndexSet *insert = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *remove = [NSMutableIndexSet indexSet];
    NSUInteger removeIdx = 1, insertIdx = 1;

    if (origContainsChirp && !currContainsChirp) {
        [remove addIndex:removeIdx++];
    } else if (!origContainsChirp && currContainsChirp) {
        [insert addIndex:insertIdx++];
    }

    if (origContainsReturn && !currContainsReturn) {
        [remove addIndex:removeIdx++];
    } else if (!origContainsReturn && currContainsReturn) {
        [insert addIndex:insertIdx++];
    }

    if (origHasArgs && !currHasArgs) {
        [remove addIndexesInRange:NSMakeRange(removeIdx, self.hook.method.numberOfArguments-2)];
    } else if (!origHasArgs && currHasArgs) {
        [insert addIndexesInRange:NSMakeRange(insertIdx, self.hook.method.numberOfArguments-2)];
    }

    [self.tableView beginUpdates];
    if (remove.count) {
        [self.tableView deleteSections:remove withRowAnimation:UITableViewRowAnimationFade];
    }
    if (insert.count) {
        [self.tableView insertSections:insert withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dynamicSectionControllers[indexPath.section] cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dynamicSectionControllers[section].sectionRowCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.totalNumberOfSections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return nil;
        }
        case 1: {
            // Only return a title if there's more than one kind of section
            TBHookType type = self.hookType;
            if (type & TBHookTypeChirpCode && type != TBHookTypeChirpCode)
                return @"Tweak format string";
            if (type & TBHookTypeReturnValue && type != TBHookTypeReturnValue)
                return @"Return value";
            if (type & TBHookTypeArguments && type != TBHookTypeArguments)
                return @"Argument values";
        }
    }

    return nil;
}

@end
