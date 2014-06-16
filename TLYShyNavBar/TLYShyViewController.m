//
//  TLYShyViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/14/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyViewController.h"

const CGFloat contractionVelocity = 40.f;

@interface TLYShyViewController ()

@property (nonatomic) CGPoint expandedCenterValue;
@property (nonatomic) CGFloat contractionAmountValue;

@property (nonatomic) CGPoint contractedCenterValue;

@end

@implementation TLYShyViewController

// convenience
- (CGPoint)expandedCenterValue
{
    return self.expandedCenter(self.view);
}

- (CGFloat)contractionAmountValue
{
    return self.contractionAmount(self.view);
}

- (CGPoint)contractedCenterValue
{
    return CGPointMake(self.expandedCenterValue.x, self.expandedCenterValue.y - self.contractionAmountValue);
}

// This method is courtesy of GTScrollNavigationBar
// https://github.com/luugiathuy/GTScrollNavigationBar
- (void)_updateSubviewsToAlpha:(CGFloat)alpha
{
    for (UIView* view in self.view.subviews)
    {
        bool isBackgroundView = view == self.view.subviews[0];
        bool isViewHidden = view.hidden || view.alpha < FLT_EPSILON;
        
        if (!isBackgroundView && !isViewHidden)
        {
            view.alpha = alpha;
        }
    }
}

- (CGFloat)updateYOffset:(CGFloat)deltaY
{
    if (self.child && deltaY < 0)
    {
        deltaY = [self.child updateYOffset:deltaY];
        self.child.view.hidden = (deltaY) < 0;
    }
    
    CGFloat newYOffset = self.view.center.y + deltaY;
    CGFloat newYCenter = MAX(MIN(self.expandedCenterValue.y, newYOffset), self.contractedCenterValue.y);
    
    self.view.center = CGPointMake(self.expandedCenterValue.x, newYCenter);
    
    if (self.hidesSubviews)
    {
        CGFloat newAlpha = 1.f - (self.expandedCenterValue.y - self.view.center.y) / self.contractionAmountValue;
        newAlpha = MIN(MAX(FLT_EPSILON, newAlpha), 1.f);
        
        [self _updateSubviewsToAlpha:newAlpha];
    }
    
    CGFloat residual = newYOffset - newYCenter;
    
    if (self.child && deltaY > 0 && residual > 0)
    {
        residual = [self.child updateYOffset:residual];
        self.child.view.hidden = residual - (newYOffset - newYCenter) > 0;
    }
    
    return residual;
}

- (CGFloat)snap:(BOOL)contract afterDelay:(NSTimeInterval)delay
{
    CGFloat newYCenter = (contract
                          ? self.expandedCenterValue.y - self.contractionAmountValue
                          : self.expandedCenterValue.y);
    
    CGFloat deltaY = newYCenter - self.view.center.y;
    CGFloat duration = fabs(deltaY/contractionVelocity);
    
    [UIView animateWithDuration:duration
                     animations:^{
                         [self updateYOffset:deltaY];
                     }];
    
    return deltaY;
}

- (void)expand
{
    self.view.center = self.expandedCenter(self.view);
    [self.child expand];
}

- (void)contract
{
    // Not needed?
}

- (void)cleanup
{
    if (self.hidesSubviews)
    {
        [self _updateSubviewsToAlpha:1.f];
    }
    [self.child cleanup];
}

@end
