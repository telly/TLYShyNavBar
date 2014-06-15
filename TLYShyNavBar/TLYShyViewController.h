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

@interface TLYShyViewController : NSObject

@property (nonatomic, weak) UIView *view;

@property (nonatomic, copy) TLYShyViewControllerExpandedCenterBlock expandedCenter;
@property (nonatomic, copy) TLYShyViewControllerContractionAmountBlock contractionAmount;

@property (nonatomic) BOOL hidesSubviews;
@property (nonatomic) BOOL hidesAfterContraction;

- (CGFloat)updateYOffset:(CGFloat)deltaY;

- (CGFloat)snap:(BOOL)contract afterDelay:(NSTimeInterval)delay;

- (void)expand;
- (void)contract;

@end
