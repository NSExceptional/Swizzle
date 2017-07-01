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
    
    [toolbar.moveItem removeFromSuperview];
    [toolbar addSubview:item];
    toolbar.moveItem = item;
    [toolbar.toolbarItems replaceObjectAtIndex:idx withObject:item];
    
    [toolbar setNeedsLayout];
    [toolbar layoutIfNeeded];
}


%group Explorer

%hook FLEXManager
%new
- (void)__toggleSwizzleMenu {
    [TBFLEXExplorerVC() presentOrDismissViewControllerFromToolbar:^UIViewController *{
        return [TBTweakRootViewController dismissAction:^{
            [self __toggleSwizzleMenu];
        }];
    } shouldDismiss:showingSwizzle completion:^{
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

%group Main
%hookf(int, UIApplicationMain, int argc, char *argv[], NSString *principalClassName, NSString *delegateClassName) {
    SwizzleInit();
    return %orig;
}
%end

%ctor {
    %init(Main);
    
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
