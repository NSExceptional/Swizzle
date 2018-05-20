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
@property (nonatomic, readonly) UILabel *infoLabel;
@end

@implementation TBInfoView

+ (instancetype)text:(NSString *)text {
    TBInfoView *view = [self new];
    view.infoLabel.text = text;
    return view;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }

    return self;
}

- (void)configure {
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _hairline = [[UIView alloc] initWithFrame:CGRectZero];

    self.infoLabel.numberOfLines = 0;
    self.infoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
//    self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

    self.backgroundColor = [UIColor colorWithWhite:0.937 alpha:1.000];
//    self.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.000];
    self.infoLabel.textColor = [UIColor blackColor];
//    self.label.textColor = [UIColor colorWithRed:0.427 green:0.427 blue:0.447 alpha:1.000];
    self.hairline.backgroundColor = [UIColor colorWithWhite:0.698 alpha:1.000];

    [self addSubview:self.infoLabel];
    [self addSubview:self.hairline];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [self.infoLabel mas__updateConstraints:^(SWZConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(10, 15, 10, 15));
//        make.edges.equalTo(self).insets(UIEdgeInsetsMake(15, 15, 15, 15));
    }];
    [self.hairline mas__updateConstraints:^(SWZConstraintMaker *make) {
        make.width.bottom.equalTo(self);
        make.height.equalTo(@0.5);
    }];

    [super updateConstraints];
}

@end
