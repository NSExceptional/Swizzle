//
//  TBSettings.h
//  TBTweakViewController
//
//  Created by Tanner on 10/6/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


/// A class to abstract the rest of the app from
/// relying on NSUserDefaults for preferences.
@interface TBSettings : NSObject

@property (nonatomic, class) BOOL expertMode;

@end
