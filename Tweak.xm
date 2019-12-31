//
//  Tweak.xm
//  Swizzle
//
//  Created by Tanner Bennett on 2016-10-06
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "Interfaces.h"


static FLEXToolbarItem * kSwizzleItem = nil;
static FLEXToolbarItem * kMoveItem = nil;
static BOOL showingSwizzle = NO;

FLEXExplorerViewController *TBFLEXExplorerVC() {
    return [(FLEXManager *)[NSClassFromString(@"FLEXManager") sharedManager] explorerViewController];
}

void FLEXExplorerToolbarSwapItemWithMoveItem(FLEXExplorerToolbar *toolbar, FLEXToolbarItem *item) {
    NSInteger idx = [toolbar.toolbarItems indexOfObject:toolbar.moveItem];
    NSMutableArray *items = toolbar.toolbarItems.mutableCopy;

    [toolbar.moveItem removeFromSuperview];
    [toolbar addSubview:item];
    toolbar.moveItem = item;
    [items replaceObjectAtIndex:idx withObject:item];
    toolbar.toolbarItems = items;
    
    [toolbar setNeedsLayout];
    [toolbar layoutIfNeeded];
}


%group Explorer

%hook FLEXManager
%new
- (void)__toggleSwizzleMenu {
    [TBFLEXExplorerVC() toggleToolWithViewControllerProvider:^UIViewController *{
        return [TBTweakRootViewController dismissAction:^{
            [self __toggleSwizzleMenu];
        }];
    } completion:^{
        showingSwizzle = !showingSwizzle;
    }];
}
%end

%hook FLEXExplorerViewController
- (void)updateButtonStates {
    %orig;
    
    kSwizzleItem.enabled = YES;
    
    if (self.currentMode == FLEXExplorerModeDefault) {
        FLEXToolbarItem *current = self.explorerToolbar.moveItem;
        if (current != kSwizzleItem) {
            kMoveItem = current;
            FLEXExplorerToolbarSwapItemWithMoveItem(self.explorerToolbar, kSwizzleItem);
        }
    } else if (kMoveItem) {
        FLEXExplorerToolbarSwapItemWithMoveItem(self.explorerToolbar, kMoveItem);
    }
}
%end

%end

%ctor {
    SwizzleInit();
    FLEXManager *flex = [NSClassFromString(@"FLEXManager") sharedManager];
    
    if (flex) {
        // Create Swizzle button
        UIImage *icon = [NSClassFromString(@"FLEXResources") globeIcon];
        kSwizzleItem = [NSClassFromString(@"FLEXToolbarItem") toolbarItemWithTitle:@"Tweak" image:icon];
        [kSwizzleItem addTarget:flex action:@selector(__toggleSwizzleMenu) forControlEvents:UIControlEventTouchUpInside];
        
        // Add it to the FLEXExplorerViewController toolbar
        %init(Explorer);
    }
}
