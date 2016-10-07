//
//  TBNumberCell.h
//  TBTweakViewController
//
//  Created by Tanner on 8/31/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBBaseValueCell.h"
#import "MirrorKit-Constants.h"


@interface TBNumberCell : TBBaseValueCell

@property (nonatomic) NSString *text;
@property (nonatomic) MKTypeEncoding numberType;

@end
