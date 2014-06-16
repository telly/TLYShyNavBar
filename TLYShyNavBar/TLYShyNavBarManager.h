//
//  TLYShyNavBarManager.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/13/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*  CLASS DESCRIPTION:
 *  ==================
 *      Manages the relationship between a scrollView and a navigation
 *  controller.
 */

@interface TLYShyNavBarManager : NSObject

/* The view controller that is part of the navigation stack
 * IMPORTANT: Must have access to navigationController
 */
@property (nonatomic, readonly) UIViewController *viewController;

/* The container to contain the extension view, if any. Exposed to
 * allow the developer to adjust content offset as necessary
 */
@property (nonatomic, readonly) UIView *extensionViewContainer;

/* The scrollView subclass that will drive the contraction/expansion */
@property (nonatomic, weak) UIScrollView *scrollView;

- (void)setExtensionView:(UIView *)view;

/* Needs to be called in viewDidLayoutSubviews */
- (void)layoutViews;
/* Needs to be called in two places.. Please refer to the demo */
- (void)scrollViewDidEndScrolling;

@end

@interface UIViewController (ShyNavBar)

@property (nonatomic, strong) TLYShyNavBarManager *shyNavBarManager;

@end
