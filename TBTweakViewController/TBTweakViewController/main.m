//
//  main.m
//  TBTweakViewController
//
//  Created by Tanner on 8/17/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TBMethodStore.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        TBMethodStoreInit();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
