//
//  TLYShyViewController.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/14/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const CGFloat contractionVelocity;

typedef CGPoint(^TLYShyViewControllerExpandedCenterBlock)(UIView *view);
typedef CGFloat(^TLYShyViewControllerContractionAmountBlock)(UIView *view);

/*  CLASS DESCRIPTION:
 *  ==================
 *      A shy view is a view that contracts when a scrolling event is
 *  triggered. We use this class to control the operations we perform on
 *  the shy view.
 *
 *      ShyViewControllers can have a child, which gets the same offset 
 *  updates as its parent. The use for this is to implement a drawer like
 *  functionality. When a parent is contracted/expanded, we want the child
 *  which is beneath the view to move the same amount so it remains hidden.
 */

@interface TLYShyViewController : NSObject

@property (nonatomic, strong) TLYShyViewController *child;

@property (nonatomic, weak) UIView *view;

@property (nonatomic, copy) TLYShyViewControllerExpandedCenterBlock expandedCenter;
@property (nonatomic, copy) TLYShyViewControllerContractionAmountBlock contractionAmount;

@property (nonatomic) BOOL hidesSubviews;

- (CGFloat)updateYOffset:(CGFloat)deltaY;

- (CGFloat)snap:(BOOL)contract afterDelay:(NSTimeInterval)delay;

- (void)expand;
- (void)contract;

- (void)cleanup;

@end
