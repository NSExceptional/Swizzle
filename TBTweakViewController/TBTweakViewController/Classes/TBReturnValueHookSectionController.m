//
//  TBReturnValueHookSectionController.m
//  TBTweakViewController
//
//  Created by Tanner on 10/9/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBReturnValueHookSectionController.h"

@implementation TBReturnValueHookSectionController

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate
                    type:(const char *)typeEncoding
            initialValue:(TBValue *)initialvalue {
    TBReturnValueHookSectionController *controller = [super delegate:delegate type:typeEncoding];
    controller.coordinator.container = initialvalue;
    return controller;
}

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate type:(const char *)typeEncoding {
    @throw NSInternalInconsistencyException;
    return nil;
}

#pragma mark Overrides

- (NSString *)typePickerTitle {
    return @"Change return type";
}

@end
