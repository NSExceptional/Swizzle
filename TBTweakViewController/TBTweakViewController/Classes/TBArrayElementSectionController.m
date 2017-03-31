//
//  TBArrayElementSectionController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/29/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBArrayElementSectionController.h"


@implementation TBArrayElementSectionController

#pragma mark Overrides

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate {
    return [super delegate:delegate type:"@"];
}

- (NSString *)typePickerTitle {
    return @"Change element type";
}

@end
