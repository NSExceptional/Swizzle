//
//  TBAddElementSectionController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/30/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBAddElementSectionController.h"
#import "TBAddValueCell.h"


@interface TBAddElementSectionController ()
@property (nonatomic, readonly) void (^onTap)();
@end
@implementation TBAddElementSectionController

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate onTap:(void (^)())tapAction {
    TBAddElementSectionController *controller = [super delegate:delegate];
    controller->_onTap = tapAction;
    return controller;
}

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate {
    @throw NSInternalInconsistencyException;
    return nil;
}

- (NSUInteger)sectionRowCount {
    return 1;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.onTap();
}

- (TBTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TBAddValueCell dequeue:self.delegate.tableView indexPath:indexPath];
}

- (BOOL)shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
