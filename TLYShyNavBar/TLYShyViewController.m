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

- (CGFloat)updateYOffset:(CGFloat)deltaY
{
    CGFloat newYOffset = self.view.center.y + deltaY;
    CGFloat newYCenter = MAX(MIN(self.expandedCenterValue.y, newYOffset), self.contractedCenterValue.y);
    
    self.view.center = CGPointMake(self.expandedCenterValue.x, newYCenter);
    
    CGFloat newAlpha = 1.f - (self.expandedCenterValue.y - self.view.center.y) / self.contractionAmountValue;
    newAlpha = MIN(MAX(FLT_EPSILON, newAlpha), 1.f);
    
    if (self.hidesSubviews)
    {
        [self _updateSubviewsToAlpha:newAlpha];
    }
    
    if (self.hidesAfterContraction)
    {
        self.view.alpha = fabs(newYCenter - self.contractedCenterValue.y) < FLT_EPSILON ? 0.f : 1.f;
    }
    
    CGFloat residual = newYOffset - newYCenter;
    return residual;
}

- (CGFloat)snap:(BOOL)contract afterDelay:(NSTimeInterval)delay
{
    CGFloat newYCenter = (contract
                          ? self.expandedCenterValue.y - self.contractionAmountValue
                          : self.expandedCenterValue.y);
    
    CGFloat deltaY = newYCenter - self.view.center.y;
    
    [UIView animateWithDuration:fabs(deltaY/contractionVelocity)
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
