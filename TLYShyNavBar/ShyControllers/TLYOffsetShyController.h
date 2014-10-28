//
//  TLYOffsetShyController.h
//  Telly
//
//  Created by Mazyad Alabduljaleel on 10/28/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyController.h"

typedef CGPoint(^TLYShyViewControllerExpandedCenterBlock)(UIView *view);
typedef CGFloat(^TLYShyViewControllerContractionAmountBlock)(UIView *view);

/** Reacts to the scroll deltas by manipulating the offset
 */
@interface TLYOffsetShyController : TLYShyController

@property (nonatomic, copy) TLYShyViewControllerExpandedCenterBlock expandedCenter;
@property (nonatomic, copy) TLYShyViewControllerContractionAmountBlock contractionAmount;

@end
