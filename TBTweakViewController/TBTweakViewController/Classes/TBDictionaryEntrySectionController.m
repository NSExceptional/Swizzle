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
@end

@implementation TBDictionaryEntrySectionController
@dynamic delegate;

+ (instancetype)delegate:(id<TBDictionarySectionDelegate>)delegate {
    return [super delegate:delegate];
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
                ip = [NSIndexPath indexPathForRow:0 inSection:1];
                return value(ip);
            }
        case 2:
            if (self.keyController.sectionRowCount == 2) {
                // Convert to first row in value section
                ip = [NSIndexPath indexPathForRow:0 inSection:1];
                return value(ip);
            } else {
                // Convert to second row in value section
                ip = [NSIndexPath indexPathForRow:1 inSection:1];
                return value(ip);
            }
        case 3:
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

- (void)textViewDidChange:(UITextView *)textView cell:(UITableViewCell *)cell {
    // Delegate to our own delegate
    [self.delegate textViewDidChange:textView cell:cell];
}

@end
