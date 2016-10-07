//
//  TBStringCell.h
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBBaseValueCell.h"


@interface TBStringCell : TBBaseValueCell

@property (nonatomic) NSString *text;

@property (nonatomic, readonly) TBValue *stringValue;
@property (nonatomic, readonly) TBValue *numberValue;
@property (nonatomic, readonly) TBValue *selectorValue;
@property (nonatomic, readonly) TBValue *classValue;

@end
