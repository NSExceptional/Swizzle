//
//  TBElementSectionController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/31/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBElementSectionController.h"


@implementation TBElementSectionController

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate {
    return [super delegate:delegate type:"@"];
}

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate object:(id)value {
    TBElementSectionController *controller = [self delegate:delegate];
    controller.coordinator.object = value;
    return controller;
}

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate type:(const char *)typeEncoding {
    @throw NSInternalInconsistencyException;
    return nil;
}

- (NSString *)typePickerTitle {
    return @"Change element type";
}

@end
