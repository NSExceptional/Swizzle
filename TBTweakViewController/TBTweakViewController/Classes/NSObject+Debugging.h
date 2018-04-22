//
//  NSObject+Debugging.h
//  TBTweakViewController
//
//  Created by Tanner on 6/30/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (Debugging)

@property (nonatomic, readonly, class) NSBundle *__bundle__;
@property (nonatomic, readonly, class) BOOL isOfMainBundle;

@end
