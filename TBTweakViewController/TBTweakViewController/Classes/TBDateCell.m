//
//  TBDateCell.m
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBDateCell.h"
#import "Masonry/Masonry.h"


@interface TBDateCell ()
@property (nonatomic, readonly) UIDatePicker *picker;
@end

@implementation TBDateCell

- (void)initSubviews {
    _picker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [self.picker addTarget:self action:@selector(dateDidChange) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.picker];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.picker mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.height.equalTo(@216);
    }];
}

#pragma mark Public interface

- (NSDate *)date {
    return self.picker.date;
}

- (void)setDate:(NSDate *)date {
    self.picker.date = date;
}

#pragma mark Date changed

- (void)dateDidChange {
    self.delegate.coordinator.object = self.picker.date;
}

@end
