//
//  TBDateCell.h
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBBaseValueCell.h"


@interface TBDateCell : TBBaseValueCell

@property (nonatomic) NSDate *date;
@property (nonatomic, readonly) TBValue *value;

@end
