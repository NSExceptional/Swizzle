//
//  TBBaseValueCell.m
//  TBTweakViewController
//
//  Created by Tanner on 8/26/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TBValueCells.h"
#import "TBValue+ValueHelpers.h"
#import "TBSwitchCell.h"

#define format(...) [NSString stringWithFormat:__VA_ARGS__]


@implementation TBBaseValueCell

- (void)describeValue:(TBValue *)value {
    TBValueType type = value.type;
    
    switch (type) {
        case TBValueTypeUnmodified:
        case TBValueTypeNilValue: {
            break;
        }
        case TBValueTypeChirpValue: {
            TBChirpCell *celll = (id)self;
            celll.text = value.chirpValue;
            break;
        }
        case TBValueTypeClass: {
            TBClassCell *celll = (id)self;
            celll.text = value.classNameValue;
            break;
        }
        case TBValueTypeSelector: {
            TBSelectorCell *celll = (id)self;
            celll.text = value.selectorValue;
            break;
        }
        case TBValueTypeInteger:
        case TBValueTypeFloat:
        case TBValueTypeDouble: {
            TBNumberCell *celll = (id)self;
            celll.text = value.numberValue.description;
            break;
        }
        case TBValueTypeString: {
            TBStringCell *celll = (id)self;
            celll.text = value.stringValue;
            break;
        }
        case TBValueTypeMutableString: {
            TBStringCell *celll = (id)self;
            celll.text = value.mutableStringValue;
            break;
        }
        case TBValueTypeDate: {
            TBDateCell *celll = (id)self;
            celll.date = value.dateValue;
            break;
        }
        case TBValueTypeColor: {
            TBColorCell *celll = (id)self;
            celll.color = value.colorValue;
            break;
        }
        case TBValueTypeObject: {
            // Should never occur because the type will be chosen by the user
            @throw NSInternalInconsistencyException;
        }
        case TBValueTypeArray:
        case TBValueTypeSet:
        case TBValueTypeMutableArray:
        case TBValueTypeMutableSet: {
            TBDetailDisclosureCell *celll = (id)self;
            celll.textLabel.text = @"Edit";
            celll.detailTextLabel.text = format(@"%ld element(s)", (long)((NSArray*)value.value).count);
            break;
        }
        case TBValueTypeDictionary:
        case TBValueTypeMutableDictionary: {
            TBDetailDisclosureCell *celll = (id)self;
            celll.textLabel.text = @"Edit";
            celll.detailTextLabel.text = format(@"%ld key-value pair(s)", (long)((NSDictionary*)value.value).count);
            break;
        }
        case TBValueTypeStruct: {
            TBDetailDisclosureCell *celll = (id)self;
            celll.textLabel.text = @"Edit";
            celll.detailTextLabel.text = TBStringFromStruct(value);
            break;
        }
    }
}

+ (NSArray<Class> *)allValueCells {
    return @[
        [TBSwitchCell class],
        [TBDetailDisclosureCell class],
        [TBChirpCell class],
        [TBStringCell class],
        [TBNumberCell class],
        [TBClassCell class],
        [TBSelectorCell class],
        [TBDateCell class],
        [TBColorCell class],
        [TBKeyValuePairCell class],
        [TBAddValueCell class]
    ];
}

@end
