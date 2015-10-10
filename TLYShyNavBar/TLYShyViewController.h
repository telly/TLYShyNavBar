//
//  TLYShyViewController.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/14/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern const CGFloat contractionVelocity;

typedef CGPoint(^TLYShyViewControllerExpandedCenterBlock)(UIView *view);
typedef CGFloat(^TLYShyViewControllerContractionAmountBlock)(UIView *view);


/** This enum is duplicated in the manager header, as to not cause headaches
 *  for users looking to update the library in Cocoapods.
 */
typedef NS_ENUM(NSInteger, TLYShyNavViewControllerFade) {
    
    TLYShyNavViewControllerFadeDisabled,
    TLYShyNavViewControllerFadeSubviews,
    TLYShyNavViewControllerFadeNavbar,
};

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

@interface TLYShyViewController : NSObject

@property (nonatomic, weak) TLYShyViewController *child;
@property (nonatomic, weak) UIView *view;

@property (nonatomic, copy) TLYShyViewControllerExpandedCenterBlock expandedCenter;
@property (nonatomic, copy) TLYShyViewControllerContractionAmountBlock contractionAmount;

@property (nonatomic) TLYShyNavViewControllerFade fadeBehavior;

@property (nonatomic, readonly) CGFloat totalHeight;

/* Sticky extension view
 */
@property (nonatomic) BOOL stickyExtensionView;

/* Sticky navigation bar
 */
@property (nonatomic) BOOL stickyNavigatiobBar;

- (CGFloat)updateYOffset:(CGFloat)deltaY;

- (CGFloat)snap:(BOOL)contract;

- (CGFloat)expand;
- (CGFloat)contract;

@end
