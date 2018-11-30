//
//  TLYShyNavBarManager.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/13/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TLYShyNavBarFade.h"


@protocol TLYShyNavBarManagerDelegate;

/** CLASS DESCRIPTION:
 *  ==================
 *      Manages the relationship between a scrollView and a view
 *  controller. Must be instantiated and assigned the scrollView
 *  that drives the contraction/expansion, then assigned to the
 *  viewController that needs the functionality. Must be assigned
 *  throught the UIViewController category:
 *      
 *  viewController.shyNavManager = ...;
 *
 */
@interface TLYShyNavBarManager : NSObject

/* The view controller that is part of the navigation stack
 * IMPORTANT: Must have access to navigationController
 */
@property (nonatomic, readonly, weak) UIViewController *viewController;

/* The scrollView subclass that will drive the contraction/expansion 
 * IMPORTANT: set this property AFTER assigning its delegate, if needed!
 */
@property (nonatomic, strong) UIScrollView *scrollView;

/* The extension view to be shown beneath the navbar
 */
@property (nonatomic, strong) UIView *extensionView;

/* The container contains the extension view, if any. Exposed to
 * allow the developer to adjust content offset as necessary.
 */
@property (nonatomic, readonly) CGRect extensionViewBounds;

/* Make the navigation bar stick to the top without collapsing
 * Deatuls to NO
 */
@property (nonatomic) BOOL stickyNavigationBar;

/* Make the extension view stick to the bottom of the navbar without
 * collapsing
 * Defaults to NO
 */
@property (nonatomic) BOOL stickyExtensionView;

/* Additional sticky offset for extension view,
 * usable to make only part of extension view visible in folded state.
 */
@property (nonatomic) CGFloat stickyOffset;

/* Control the resistance when scrolling up/down before the navbar
 * expands/contracts again.
 */
@property (nonatomic) CGFloat expansionResistance;      // default 200
@property (nonatomic) CGFloat contractionResistance;    // default 0

/* Choose how the navbar fades as it contracts/expands.
 * Defaults to FadeSubviews
 */
@property (nonatomic) TLYShyNavBarFade fadeBehavior;

/* Use this to set if the controller have any kind of custom refresh control
 */
@property (nonatomic) BOOL hasCustomRefreshControl;

/* Set NO to disable shyNavBar behavior temporarily.
 * Defaults to NO
 */
@property (nonatomic) BOOL disable;

/* Use this to be notified about contraction and expansion events.
 */
@property (nonatomic, weak) id<TLYShyNavBarManagerDelegate> delegate;

@end

/* PROTOCOL DESCRIPTION:
 * =====================
 *     This protocol is used to notify an optional TLYShyNavBarManager's delegate
 * when a contraction or expansion finishes animating.
 */
@protocol TLYShyNavBarManagerDelegate <NSObject>

@optional

- (void)shyNavBarManagerDidBecomeFullyContracted:(TLYShyNavBarManager *) shyNavBarManager;
- (void)shyNavBarManagerDidFinishContracting:(TLYShyNavBarManager *) shyNavBarManager;
- (void)shyNavBarManagerDidFinishExpanding:(TLYShyNavBarManager *) shyNavBarManager;

@end


/** CATEGORY DESCRIPTION:
 *  =====================
 *      The category described in the TLYShyNavBarManager usage, and it
 *  simply uses associated objects to attatch a TLYShyNavBar to the 
 *  designated view controller.
 *
 *      We also perform some swizzling to pass notifications to the 
 *  TLYShyNavBar. Things like, viewDidLayoutSubviews, viewWillAppear and
 *   Disappear, ... etc.
 */

@interface UIViewController (ShyNavBar)

/* Initially, this is nil, but created for you when you access it */
@property (nonatomic, strong) TLYShyNavBarManager *shyNavBarManager;

/*
 * Set the TLYShyNavBarManager while also specifying a view controller
 */
- (void)setShyNavBarManager:(TLYShyNavBarManager *)shyNavBarManager
             viewController:(UIViewController *)viewController;

/* Use this to find out if a TLYShyNavBarManager instance was associated
 * to this view controller, without triggering its creation and association.
 */
- (BOOL)isShyNavBarManagerPresent;

@end
