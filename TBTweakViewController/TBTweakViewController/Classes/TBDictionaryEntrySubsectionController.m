//
//  TBDictionaryEntrySubsectionController.m
//  TBTweakViewController
//
//  Created by Tanner on 3/30/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBDictionaryEntrySubsectionController.h"
#import "TBDictionaryEntrySectionController.h"


@implementation TBDictionaryEntrySubsectionController

+ (instancetype)section:(TBDictionaryEntrySectionController *)section {
    TBDictionaryEntrySubsectionController *controller = [super delegate:section.delegate type:"@"];
    controller->_section = section;
    return controller;
}

+ (instancetype)delegate:(id<TBSectionControllerDelegate>)delegate {
    @throw NSInternalInconsistencyException;
    return nil;
}

- (void)setCurrentResponder:(UIResponder *)currentResponder {
    super.currentResponder = currentResponder;
    self.section.currentResponder = currentResponder;
}

@end
