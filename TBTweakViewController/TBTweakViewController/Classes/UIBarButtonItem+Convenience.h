//
//  UIBarButtonItem+Convenience.h
//  TBTweakViewController
//
//  Created by Tanner on 3/9/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIBBItem) {
    UIBBItemDone = UIBarButtonSystemItemDone,
    UIBBItemCancel = UIBarButtonSystemItemCancel,
    UIBBItemEdit = UIBarButtonSystemItemEdit,
    UIBBItemSave = UIBarButtonSystemItemSave,
    UIBBItemAdd = UIBarButtonSystemItemAdd,
    UIBBItemFlexibleSpace = UIBarButtonSystemItemFlexibleSpace,
    UIBBItemFixedSpace = UIBarButtonSystemItemFixedSpace,
    UIBBItemCompose = UIBarButtonSystemItemCompose,
    UIBBItemReply = UIBarButtonSystemItemReply,
    UIBBItemAction = UIBarButtonSystemItemAction,
    UIBBItemOrganize = UIBarButtonSystemItemOrganize,
    UIBBItemBookmarks = UIBarButtonSystemItemBookmarks,
    UIBBItemSearch = UIBarButtonSystemItemSearch,
    UIBBItemRefresh = UIBarButtonSystemItemRefresh,
    UIBBItemStop = UIBarButtonSystemItemStop,
    UIBBItemCamera = UIBarButtonSystemItemCamera,
    UIBBItemTrash = UIBarButtonSystemItemTrash,
    UIBBItemPlay = UIBarButtonSystemItemPlay,
    UIBBItemPause = UIBarButtonSystemItemPause,
    UIBBItemRewind = UIBarButtonSystemItemRewind,
    UIBBItemFastForward = UIBarButtonSystemItemFastForward,
    UIBBItemUndo = UIBarButtonSystemItemUndo,
    UIBBItemRedo = UIBarButtonSystemItemRedo,
    UIBBItemPageCurl = UIBarButtonSystemItemPageCurl,
};

@interface UIBarButtonItem (Convenience)

+ (instancetype)item:(UIBBItem)item;
+ (instancetype)item:(UIBBItem)item target:(id)target action:(SEL)action;

@end
