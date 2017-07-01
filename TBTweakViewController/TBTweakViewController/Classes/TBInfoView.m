//
//  TBInfoView.m
//  TBTweakViewController
//
//  Created by Tanner on 3/29/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBInfoView.h"
#import "Masonry/Masonry.h"


@interface TBInfoView ()
@property (nonatomic, readonly) UILabel *label;
@end

@implementation TBInfoView

+ (instancetype)text:(NSString *)text {
    TBInfoView *view = [self new];
    view.label.text  = text;
    return view;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }

    return self;
}

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (void)configure {
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _hairline = [[UIView alloc] initWithFrame:CGRectZero];

    self.label.numberOfLines = 0;
    self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
//    self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

    self.backgroundColor = [UIColor colorWithWhite:0.937 alpha:1.000];
//    self.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.000];
    self.label.textColor = [UIColor blackColor];
//    self.label.textColor = [UIColor colorWithRed:0.427 green:0.427 blue:0.447 alpha:1.000];
    self.hairline.backgroundColor = [UIColor colorWithWhite:0.698 alpha:1.000];

    [self addSubview:self.label];
    [self addSubview:self.hairline];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self.label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(10, 15, 10, 15));
//        make.edges.equalTo(self).insets(UIEdgeInsetsMake(15, 15, 15, 15));
    }];
    [self.hairline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.bottom.equalTo(self);
        make.height.equalTo(@0.5);
    }];

    [super updateConstraints];
}

@end
