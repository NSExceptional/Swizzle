//
//  TBBaseValueCell.m
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBBaseValueCell.h"


@implementation TBBaseValueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubviews];
        //        self.textLabel.font = [UIFont fontWithName:@"Menlo-Regular" size:17];
    }
    
    return self;
}

- (void)initSubviews { }

+ (BOOL)requiresConstraintBasedLayout { return self != TBBaseValueCell.class; }

@end
