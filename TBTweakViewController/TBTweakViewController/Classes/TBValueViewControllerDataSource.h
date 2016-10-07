//
//  TBValueViewControllerDataSource.h
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBValueViewController.h"


@interface TBValueViewControllerDataSource : NSObject

+ (instancetype)dataSourceForViewController:(UIViewController *)vc valueType:(MKTypeEncoding)type;

- (void)trySetInitialValue:(TBValue *)value;
- (void)getValueIfEditing;

@property (nonatomic, readonly) TBValue *value;


// Internal stuff

@property (nonatomic, copy) NSDate   *date;
@property (nonatomic, copy) NSString *string;
@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, copy) UIColor  *color;
@property (nonatomic, copy) NSString *chirpString;

@property (nonatomic) UIResponder *currentResponder;

@end
