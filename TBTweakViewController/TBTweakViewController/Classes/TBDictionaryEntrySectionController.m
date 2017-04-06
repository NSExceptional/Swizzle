//
//  TBDictionaryEntrySectionController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/30/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBDictionaryEntrySectionController.h"
#import "TBDictionaryKeySectionController.h"
#import "TBDictionaryValueSectionController.h"

typedef id (^IndexPathBlock)(NSIndexPath *ip);
@interface TBDictionaryEntrySectionController ()
@property (nonatomic, readonly) TBDictionaryKeySectionController *keyController;
@property (nonatomic, readonly) TBDictionaryValueSectionController *valueController;
@property (nonatomic, readonly) NSNull *null;
@end

@implementation TBDictionaryEntrySectionController
@dynamic delegate;

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate {
    TBDictionaryEntrySectionController *controller = [super delegate:delegate];
    controller->_keyController   = [TBDictionaryKeySectionController section:controller];
    controller->_valueController = [TBDictionaryValueSectionController section:controller];
    controller->_null            = [NSNull null];
    return controller;
}

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate key:(id)key value:(id)value {
    TBDictionaryEntrySectionController *controller = [self delegate:delegate];
    controller.keyController.coordinator.object   = key;
    controller.valueController.coordinator.object = value;

    return controller;
}

#pragma mark Public

- (id)key {
    return self.keyController.coordinator.object ?: _null;
}

- (id)value {
    return self.valueController.coordinator.object ?: _null;
}

#pragma mark Private

- (id)delegateIndexPath:(NSIndexPath *)ip key:(IndexPathBlock)key value:(IndexPathBlock)value {
    switch (ip.row) {
        case 0:
            return key(ip);
        case 1:
            if (self.keyController.sectionRowCount == 2) {
                return key(ip);
            } else {
                // Convert to first row in value section
                ip = [NSIndexPath indexPathForRow:0 inSection:ip.section];
                return value(ip);
            }
        case 2:
            if (self.keyController.sectionRowCount == 2) {
                // Convert to first row in value section
                ip = [NSIndexPath indexPathForRow:0 inSection:ip.section];
                return value(ip);
            } else {
                // Convert to second row in value section
                ip = [NSIndexPath indexPathForRow:1 inSection:ip.section];
                return value(ip);
            }
        case 3:
            // Convert to second row in value section
            ip = [NSIndexPath indexPathForRow:1 inSection:ip.section];
            return value(ip);
        default:
            @throw NSGenericException;
            return nil;
    }
}

#pragma mark Overrides

- (NSUInteger)sectionRowCount {
    return self.keyController.sectionRowCount + self.valueController.sectionRowCount;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self delegateIndexPath:indexPath key:^id(NSIndexPath *ip) {
        [self.keyController didSelectRowAtIndexPath:ip]; return nil;
    } value:^id(NSIndexPath *ip) {
        [self.valueController didSelectRowAtIndexPath:ip]; return nil;
    }];
}

- (TBTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self delegateIndexPath:indexPath key:^id(NSIndexPath *ip) {
        return [self.keyController cellForRowAtIndexPath:ip];
    } value:^id(NSIndexPath *ip) {
        return [self.valueController cellForRowAtIndexPath:ip];
    }];
}

- (BOOL)shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self delegateIndexPath:indexPath key:^id(NSIndexPath *ip) {
        return @([self.keyController shouldHighlightRowAtIndexPath:ip]);
    } value:^id(NSIndexPath *ip) {
        return @([self.valueController shouldHighlightRowAtIndexPath:ip]);
    }] boolValue];
}

#pragma mark TBValueCellDelegate

- (UITableView *)tableView {
    return self.delegate.tableView;
}

@end
