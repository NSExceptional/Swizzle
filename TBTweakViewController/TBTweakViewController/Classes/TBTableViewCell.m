//
//  TBTableViewCell.m
//  TBTweakViewController
//
//  Created by Tanner on 3/15/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBValueCells.h"


@implementation TBTableViewCell

#pragma mark Overrides

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:[self class].defaultStyle reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubviews];
    }

    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithStyle:[self class].defaultStyle reuseIdentifier:[self class].reuseID];
}

- (id)init {
    return [self initWithStyle:[self class].defaultStyle reuseIdentifier:[self class].reuseID];
}

- (void)initSubviews { }

+ (BOOL)requiresConstraintBasedLayout { return YES; }

#pragma mark Public

+ (NSString *)reuseID { return NSStringFromClass(self); }

+ (UITableViewCellStyle)defaultStyle {
    return UITableViewCellStyleSubtitle;
}

+ (NSString *)reuseIdentifierForValueType:(TBValueType)type {
    switch (type) {
        case TBValueTypeUnmodified:
        case TBValueTypeNilValue:
            return nil;
        case TBValueTypeChirpValue:
            return TBChirpCell.reuseID;
        case TBValueTypeClass:
            return TBClassCell.reuseID;
        case TBValueTypeSelector:
            return TBSelectorCell.reuseID;
        case TBValueTypeInteger:
        case TBValueTypeFloat:
        case TBValueTypeDouble:
            return TBNumberCell.reuseID;
        case TBValueTypeString:
        case TBValueTypeMutableString:
            return TBStringCell.reuseID;
        case TBValueTypeDate:
            return TBDateCell.reuseID;
        case TBValueTypeColor:
            return TBColorCell.reuseID;
        case TBValueTypeObject:
        case TBValueTypeArray:
        case TBValueTypeDictionary:
        case TBValueTypeSet:
        case TBValueTypeMutableArray:
        case TBValueTypeMutableSet:
        case TBValueTypeMutableDictionary:
        case TBValueTypeStruct:
            return TBDetailDisclosureCell.reuseID;
    }

    @throw NSInternalInconsistencyException;
    return nil;
}

+ (instancetype)dequeue:(UITableView *)tableView indexPath:(NSIndexPath *)ip {
    return (id)[tableView dequeueReusableCellWithIdentifier:self.reuseID forIndexPath:ip];
}

@end
