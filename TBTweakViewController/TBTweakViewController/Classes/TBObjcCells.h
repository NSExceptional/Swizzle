//
//  TBObjcCells.h
//  TBTweakViewController
//
//  Created by Tanner on 3/17/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

#import "TBTextFieldCell.h"


/// Abstract class used by TBClassCell and TBSelectorCell to specify which characters to allow
@interface TBObjcCell : TBTextFieldCell
@property (nonatomic, readonly, class) NSCharacterSet *disallowedCharacters;
@end

@interface TBClassCell : TBObjcCell
@end

@interface TBSelectorCell : TBObjcCell
@end
