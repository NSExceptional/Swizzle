//
//  Interfaces.h
//  Muta
//
//  Created by Tanner Bennett on 2016-10-06
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#pragma mark Imports

#import "TBTweakRootViewController.h"
#import "SwizzleInit.h"


#pragma mark Macros

/// ie PropertyForKey(dateLabel, UILabel *, UITableViewCell)
#define PropertyForKey(key, propertyType, class) \
@interface class (key) @property (readonly) propertyType key; @end \
@implementation class (key) - (propertyType)key { return [self valueForKey:@"_"@#key]; } @end

#define RWPropertyInf(key, propertyType, class) \
@interface class (key) @property propertyType key; @end

#define Alert(TITLE,MSG) [[[UIAlertView alloc] initWithTitle:(TITLE) \
message:(MSG) \
delegate:nil \
cancelButtonTitle:@"OK" \
otherButtonTitles:nil] show]


#pragma mark Interfaces

typedef NS_ENUM(NSUInteger, FLEXExplorerMode) {
    FLEXExplorerModeDefault,
    FLEXExplorerModeSelect,
    FLEXExplorerModeMove
};

@interface FLEXToolbarItem : UIButton
+ (instancetype)toolbarItemWithTitle:(NSString *)title image:(UIImage *)image;
@end

@interface FLEXExplorerToolbar : UIView
@property FLEXToolbarItem *moveItem;
@property NSMutableArray<FLEXToolbarItem*> *toolbarItems;
@end

@interface FLEXExplorerViewController : UIViewController
@property (readonly) FLEXExplorerMode currentMode;
@property FLEXExplorerToolbar *explorerToolbar;
- (void)toggleToolWithViewControllerProvider:(UIViewController *(^)())future completion:(void(^)())completion;
@end

@interface FLEXManager : NSObject
+ (instancetype)sharedManager;
- (void)__toggleSwizzleMenu;
@property UIWindow *explorerWindow;
@property FLEXExplorerViewController *explorerViewController;
@end

@interface FLEXResources : NSObject

+ (UIImage *)closeIcon;
+ (UIImage *)dragHandle;
+ (UIImage *)globeIcon;
+ (UIImage *)hierarchyIndentPattern;
+ (UIImage *)listIcon;
+ (UIImage *)moveIcon;
+ (UIImage *)selectIcon;

+ (UIImage *)jsonIcon;
+ (UIImage *)textPlainIcon;
+ (UIImage *)htmlIcon;
+ (UIImage *)audioIcon;
+ (UIImage *)jsIcon;
+ (UIImage *)plistIcon;
+ (UIImage *)textIcon;
+ (UIImage *)videoIcon;
+ (UIImage *)xmlIcon;
+ (UIImage *)binaryIcon;

@end
