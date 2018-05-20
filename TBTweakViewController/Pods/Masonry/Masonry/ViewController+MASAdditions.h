//
//  UIViewController+MASAdditions.h
//  Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "MASUtilities.h"
#import "MASConstraintMaker.h"
#import "MASViewAttribute.h"

#ifdef MAS_VIEW_CONTROLLER

@interface MAS_VIEW_CONTROLLER (MASAdditions)

/**
 *	following properties return a new SWZViewAttribute with appropriate UILayoutGuide and NSLayoutAttribute
 */
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__topLayoutGuide;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__bottomLayoutGuide;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__topLayoutGuideTop;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__topLayoutGuideBottom;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__bottomLayoutGuideTop;
@property (nonatomic, strong, readonly) SWZViewAttribute *mas__bottomLayoutGuideBottom;


@end

#endif
