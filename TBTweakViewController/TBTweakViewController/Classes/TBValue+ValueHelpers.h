//
//  TBValue+ValueHelpers.h
//  TBTweakViewController
//
//  Created by Tanner on 10/6/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBValue.h"
@class UIColor;


/// The helpers in this category will raise exceptions
/// when you try to access the specified value when the
/// type does not match that of the accessor.
@interface TBValue (ValueHelpers)

@property (nonatomic, readonly) NSString *chirpValue;
@property (nonatomic, readonly) NSString *classNameValue;
@property (nonatomic, readonly) NSString *selectorValue;
@property (nonatomic, readonly) NSNumber *numberValue;
@property (nonatomic, readonly) NSString *stringValue;
@property (nonatomic, readonly) NSMutableString *mutableStringValue;
@property (nonatomic, readonly) NSDate *dateValue;
@property (nonatomic, readonly) UIColor *colorValue;
@property (nonatomic, readonly) NSArray *arrayValue;
@property (nonatomic, readonly) NSSet *setValue;
@property (nonatomic, readonly) NSDictionary *dictionaryValue;
@property (nonatomic, readonly) NSMutableArray *mutableArrayValue;
@property (nonatomic, readonly) NSMutableSet *mutableSetValue;
@property (nonatomic, readonly) NSMutableDictionary *mutableDictionaryValue;

@end
