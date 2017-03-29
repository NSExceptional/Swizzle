//
//  TBTextEditorView.m
//  TBTweakViewController
//
//  Created by Tanner on 3/28/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBTextEditorView.h"


@implementation TBTextEditorView

+ (instancetype)delegate:(id<UITextViewDelegate>)delegate font:(UIFont *)font {
    TBTextEditorView *view = [self new];
    view.delegate = delegate;
    view.font = font;
    return view;
}

- (id)init {
    return [self initWithFrame:CGRectZero textContainer:nil];
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame textContainer:nil];
}

- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self configure];
    }

    return self;
}

- (void)configure {
    self.text               = @"";
    self.scrollEnabled      = NO;
    self.textContainerInset = UIEdgeInsetsMake(0, 0, -2.5, 0);

    self.autocorrectionType     = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

@end
