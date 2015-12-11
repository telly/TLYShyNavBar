//
//  TLYShyViewController.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/14/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TLYShyParent.h"
#import "TLYShyChild.h"
#import "../TLYShyNavBarFade.h"


extern const CGFloat contractionVelocity;

typedef CGPoint(^TLYShyViewControllerExpandedCenterBlock)(UIView *view);
typedef CGFloat(^TLYShyViewControllerContractionAmountBlock)(UIView *view);


/*  CLASS DESCRIPTION:
 *  ==================
 *      A shy view is a view that contracts when a scrolling event is
 *  triggered. We use this class to control the operations we perform on
 *  the shy view.
 *
 *      We are making some dangerous assumtions here!!! Most importantly,
 *  the TLYShyViewController can only be a maximum depth of 2. Adding a
 *  child to an already childified node is not supported.
 */

@interface TLYShyViewController : NSObject <TLYShyChild>

@property (nonatomic, weak) id<TLYShyChild> child;
@property (nonatomic, weak) id<TLYShyParent> parent;
@property (nonatomic, weak) TLYShyViewController *subShyController;
@property (nonatomic, weak) UIView *view;

@property (nonatomic) TLYShyNavBarFade fadeBehavior;

/* Sticky means it will always stay in expanded state
 */
@property (nonatomic) BOOL sticky;

- (void)offsetCenterBy:(CGPoint)deltaPoint;
- (CGFloat)updateYOffset:(CGFloat)deltaY;

- (CGFloat)snap:(BOOL)contract;

- (CGFloat)expand;
- (CGFloat)contract;

@end


@interface TLYShyViewController (AsParent) <TLYShyParent>
@end
