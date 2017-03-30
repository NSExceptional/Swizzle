//
//  TBValueCoordinator.h
//  TBTweakViewController
//
//  Created by Tanner on 3/30/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBValue.h"


@interface TBValueCoordinator : NSObject

+ (instancetype)coordinateType:(TBValueType)type;

@property (nonatomic) TBValue *container;

@property (nonatomic) NSString *string;
@property (nonatomic) NSNumber *number;
@property (nonatomic) NSNumber *integer;
@property (nonatomic) NSNumber *singleFloat;
@property (nonatomic) NSNumber *doubleFloat;
@property (nonatomic) NSString *chirpString;

@property (nonatomic) id object;
@property (nonatomic) Class classObject;

@property (nonatomic) TBValueType valueType;

@end
