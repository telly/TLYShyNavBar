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

@property (nonatomic, readonly) UIViewController *viewController;
@property (nonatomic, readonly) UIView *extensionViewsContainer;

@property (nonatomic, weak) UIScrollView *scrollView;

- (void)addExtensionView:(UIView *)view;

- (void)layoutViews;
- (void)scrollViewDidEndScrolling;

- (void)cleanup;

@end

@interface UIViewController (ShyNavBar)

@property (nonatomic, strong) TLYShyNavBarManager *shyNavBarManager;

@end
