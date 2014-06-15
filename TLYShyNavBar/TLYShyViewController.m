//
//  TLYShyViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/14/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyViewController.h"

const CGFloat contractionVelocity = 140.f;

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

- (CGFloat)_updateYOffset:(CGFloat)deltaY overrideLimit:(BOOL)override
{
    if (self.child && deltaY < 0)
    {
        deltaY = [self.child updateYOffset:deltaY];
    }
    
    CGFloat newYOffset = self.view.center.y + deltaY;
    CGFloat newYCenter = override ? newYOffset : MAX(MIN(self.expandedCenterValue.y, newYOffset), self.contractedCenterValue.y);
    
    self.view.center = CGPointMake(self.expandedCenterValue.x, newYCenter);
    
    if (self.hidesSubviews)
    {
        CGFloat newAlpha = 1.f - (self.expandedCenterValue.y - self.view.center.y) / self.contractionAmountValue;
        newAlpha = MIN(MAX(FLT_EPSILON, newAlpha), 1.f);
    
        [self _updateSubviewsToAlpha:newAlpha];
    }
    
    CGFloat residual = newYOffset - newYCenter;
    self.child.view.center = CGPointMake(self.child.view.center.x, self.child.view.center.y + deltaY - residual);
    
    if (self.child && deltaY > 0)
    {
        residual = [self.child updateYOffset:residual];
    }
    
    return residual;
}

- (CGFloat)updateYOffset:(CGFloat)deltaY
{
    return [self _updateYOffset:deltaY overrideLimit:NO];
}

- (CGFloat)snap:(BOOL)contract afterDelay:(NSTimeInterval)delay
{
    CGFloat newYCenter = (contract
                          ? self.expandedCenterValue.y - self.contractionAmountValue
                          : self.expandedCenterValue.y);
    
    CGFloat deltaY = newYCenter - self.view.center.y;
    CGFloat duration = fabs(deltaY/contractionVelocity);
    
    if (contract)
    {
        CGFloat childDelta = [self.child snap:contract afterDelay:delay];
        delay = fabs(childDelta/contractionVelocity);
        
        deltaY += childDelta;
    }
    else
    {
        deltaY += [self.child snap:contract afterDelay:delay+duration];
    }
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self updateYOffset:deltaY];
                     } completion:nil];
    
    return deltaY;
}

- (void)expand
{
    self.view.center = self.expandedCenter(self.view);
}

- (void)contract
{
    
}

@end
