//
//  UIViewController+BetterLayoutGuides.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/21/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*  CATEGORY DESCRIPTION:
 *  =====================
 *      Apparently, Apple messed up when they implemented autolayout
 *  somehow, so when we have child view controllers, they get wrong
 *  layout guides. This helps accomodate that problem.
 *
 *  Courtesy of http://stackoverflow.com/questions/19140530/toplayoutguide-in-child-view-controller
 */

@interface UIViewController (BetterLayoutGuides)

@property (nonatomic, readonly) id<UILayoutSupport> tly_topLayoutGuide;
@property (nonatomic, readonly) id<UILayoutSupport> tly_bottomLayoutGuide;

@end
