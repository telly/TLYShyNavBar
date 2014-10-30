//
//  TLYBoundsShyController.h
//  Telly
//
//  Created by Mazyad Alabduljaleel on 10/28/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyController.h"

/** We need the scroll view to undo the content offset */
typedef void(^TLYShyViewControllerCancelScrollBlock)(CGFloat deltaY);
typedef UINavigationBar *(^TLYShyViewControllerNavbarBlock)();

/** Reacts to the scroll deltas by manipulating the bounds
 */
@interface TLYBoundsShyController : TLYShyController

@property (nonatomic, copy) TLYShyViewControllerCancelScrollBlock cancelScrollBlock;
@property (nonatomic, copy) TLYShyViewControllerNavbarBlock navbarBlock;

@end
