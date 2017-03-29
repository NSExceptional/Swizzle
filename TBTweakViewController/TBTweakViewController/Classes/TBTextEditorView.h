//
//  TBTextEditorView.h
//  TBTweakViewController
//
//  Created by Tanner on 3/28/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TBTextEditorView : UITextView

+ (instancetype)delegate:(id<UITextViewDelegate>)delegate font:(UIFont *)font;

@end
