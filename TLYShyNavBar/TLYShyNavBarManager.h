//
//  TLYShyNavBarManager.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/13/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/** This enum helps control the navigation bar fade behavior.
 *  NOTE: It is duplicated in the ShyNavController header for now.
 */
typedef NS_ENUM(NSInteger, TLYShyNavBarFade) {
    
    TLYShyNavBarFadeDisabled,
    TLYShyNavBarFadeSubviews,
    TLYShyNavBarFadeNavbar,
};

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

/* Sticky extension view
 */
@property (nonatomic) BOOL stickyExtensionView;

/* Sticky navigation bar
 */
@property (nonatomic) BOOL stickyNavigatiobBar;

/* Control the resistance when scrolling up/down before the navbar 
 * expands/contracts again.
 */
@property (nonatomic) CGFloat expansionResistance;      // default 200
@property (nonatomic) CGFloat contractionResistance;    // default 0

/* Choose how the navbar fades as it contracts/expands.
 * Defaults to FadeSubviews
 */
@property (nonatomic) TLYShyNavBarFade fadeBehavior;

/* Set NO to disable shyNavBar behavior temporarily.
 * Defaults to NO
 */
@property (nonatomic) BOOL disable;

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

@end


/*  DEPRECATED:
 *  ===========
 *      Please move away from using these properties, as they will be
 *  removed in the next major release.
 */
@interface TLYShyNavBarManager (Deprecated)

@property (nonatomic, getter = isAlphaFadeEnabled) BOOL alphaFadeEnabled
DEPRECATED_MSG_ATTRIBUTE("use fadeBehavior = TLYShyNavBarFade(Subviews or None)");

@property (nonatomic, getter = isAlphaFadeEntireNavBarEnabled) BOOL alphaFadeEntireNavBar
DEPRECATED_MSG_ATTRIBUTE("use fadeBehavior = TLYShyNavBarFadeNavbar");

@end