//
//  TBAlertAction.m
//  Alert Controller Test
//
//  Created by Tanner on 12/3/14.
//  Copyright (c) 2014 Tanner. All rights reserved.
//

#import "TBAlertAction.h"

@implementation TBAlertAction

- (id)initWithTitle:(NSString *)title {
    NSParameterAssert(title);
    
    self = [super init];
    if (self) {
        _title   = title;
        _enabled = YES;
        _style   = TBAlertActionStyleNoAction;
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title block:(TBAlertActionBlock)block {
    NSParameterAssert(block);
    self = [self initWithTitle:title];
    if (self) {
        _block = block;
        _style = TBAlertActionStyleBlock;
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    NSParameterAssert(target); NSParameterAssert(action);
    self = [self initWithTitle:title];
    
    if (self && target && action) {
        _target = target;
        _action = action;
        _style = TBAlertActionStyleTarget;
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title target:(id)target action:(SEL)action object:(id)object {
    self = [self initWithTitle:title target:target action:action];
    if (self) {
        _object = object;
        _style  = TBAlertActionStyleTargetObject;
    }
    
    return self;
}

- (void)perform {
    [self perform:@[]];
}

- (void)perform:(NSArray *)textFieldInputStrings {
    if (!textFieldInputStrings)
        textFieldInputStrings = @[];
    
    switch (self.style) {
        case TBAlertActionStyleNoAction:
            break;
        case TBAlertActionStyleBlock: {
            
            if (self.block)
                self.block(textFieldInputStrings);
            break;
        }
        case TBAlertActionStyleTarget: {
            
            IMP imp = [self.target methodForSelector:self.action];
            void (*func)(id, SEL) = (void *)imp;
            
            if ([self.target respondsToSelector:self.action])
                func(self.target, self.action);
            break;
        }
        case TBAlertActionStyleTargetObject: {
            
            IMP imp = [self.target methodForSelector:self.action];
            void (*func)(id, SEL, id) = (void *)imp;
            
            if ([self.target respondsToSelector:self.action])
                func(self.target, self.action, self.object);
            break;
        }
    }
}

@end
