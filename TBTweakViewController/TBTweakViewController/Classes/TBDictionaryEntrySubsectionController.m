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

+ (instancetype)delegate:(id<TBValueSectionDelegate>)delegate
                 section:(TBDictionaryEntrySectionController *)section {
    TBDictionaryEntrySubsectionController *controller = [super delegate:delegate type:"@"];
    controller->_section = section;
    return controller;
}

+ (instancetype)delegate:(id<TBValueSectionDelegate>)delegate {
    @throw NSInternalInconsistencyException;
    return nil;
}

- (void)setCurrentResponder:(UIResponder *)currentResponder {
    super.currentResponder = currentResponder;
    self.section.currentResponder = currentResponder;
}

@end
