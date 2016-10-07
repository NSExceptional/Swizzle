//
//  TBBaseValueCell.h
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBValue.h"


@protocol TBTextViewCellResizing <NSObject>
- (void)textViewDidChange:(UITextView *)textView cell:(UITableViewCell *)cell;
@end

@protocol TBValueCellDelegate <TBTextViewCellResizing>

@property (nonatomic) NSDate *date;
@property (nonatomic) NSString *string;
@property (nonatomic) NSNumber *number;
@property (nonatomic) NSString *chirpString;

@property (nonatomic) UIResponder *currentResponder;

@end


@interface TBBaseValueCell : UITableViewCell

- (void)initSubviews;

@property (nonatomic, weak) id<TBValueCellDelegate> delegate;

@end
