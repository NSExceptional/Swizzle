//
//  NSError+Message.m
//  TBTweakViewController
//
//  Created by Tanner on 8/19/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "NSError+Message.h"


@implementation NSError (Message)

+ (NSError *)error:(NSString *)message {
    return [NSError errorWithDomain:@"TBTweaks" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(message, @""),
                                                                  NSLocalizedFailureReasonErrorKey: NSLocalizedString(message, @"")}];
}

@end
