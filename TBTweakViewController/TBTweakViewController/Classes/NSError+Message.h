//
//  NSError+Message.h
//  TBTweakViewController
//
//  Created by Tanner on 8/19/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSError (Message)

+ (NSError *)error:(NSString *)message;

@end
