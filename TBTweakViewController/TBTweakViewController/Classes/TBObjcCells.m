//
//  TBObjcCells.m
//  TBTweakViewController
//
//  Created by Tanner on 3/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBObjcCells.h"


@implementation TBObjcCell
@dynamic disallowedCharacters;
static NSString *_bothAllowed = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_$1234567890";

- (BOOL)textField:(UITextField *)textField shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:text];

    static NSCharacterSet *allowedFirstCharacters = nil;
    static NSString *firstAllowedChars = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_$";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allowedFirstCharacters = [NSCharacterSet characterSetWithCharactersInString:firstAllowedChars];
    });

    // Classes must start with letter, _, or $
    if (![allowedFirstCharacters characterIsMember:[newString characterAtIndex:0]]) {
        return NO;
    }

    return [text rangeOfCharacterFromSet:[self class].disallowedCharacters].location == NSNotFound;
}

@end


@implementation TBClassCell
static NSCharacterSet *_classDisallowed = nil;
+ (NSCharacterSet *)disallowedCharacters {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *allowed = [_bothAllowed stringByAppendingString:@"."];
        _classDisallowed = [NSCharacterSet characterSetWithCharactersInString:allowed].invertedSet;
    });

    return _classDisallowed;
}
@end

@implementation TBSelectorCell
static NSCharacterSet *_selDisallowed = nil;
+ (NSCharacterSet *)disallowedCharacters {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *allowed = [_bothAllowed stringByAppendingString:@":"];
        _selDisallowed = [NSCharacterSet characterSetWithCharactersInString:allowed].invertedSet;
    });

    return _selDisallowed;
}
@end
