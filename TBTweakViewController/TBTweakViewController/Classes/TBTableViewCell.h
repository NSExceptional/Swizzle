//
//  TBTableViewCell.h
//  TBTweakViewController
//
//  Created by Tanner on 3/15/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBValue.h"


@interface TBTableViewCell : UITableViewCell

/// Defaults to class name
@property (nonatomic, readonly, class) NSString *reuseID;
/// Subtitle
@property (nonatomic, readonly, class) UITableViewCellStyle defaultStyle;

- (void)initSubviews;
+ (NSString *)reuseIdentifierForValueType:(TBValueType)type;

@end
