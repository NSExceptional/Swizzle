//
//  NSMapTable+Subscripting.h
//  TBTweakViewController
//
//  Created by Tanner on 8/24/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMapTable<KeyType, ObjectType> (Subscripting)

- (ObjectType)objectForKeyedSubscript:(KeyType)key;
- (void)setObject:(ObjectType)obj forKeyedSubscript:(KeyType)key;

@end
