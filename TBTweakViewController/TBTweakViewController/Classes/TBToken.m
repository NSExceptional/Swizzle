//
//  TBToken.m
//  TBTweakViewController
//
//  Created by Tanner on 3/22/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBToken.h"


@implementation TBToken

+ (instancetype)string:(NSString *)string options:(TBWildcardOptions)options {
    TBToken *token  = [self new];
    token->_string  = string;
    token->_options = options;
    return token;
}

@end
