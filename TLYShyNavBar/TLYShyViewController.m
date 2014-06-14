//
//  TLYShyViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/14/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyViewController.h"

@interface TLYShyViewController ()

@property (nonatomic) CGPoint expandedCenterValue;
@property (nonatomic) CGFloat contractionAmountValue;

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
    CGFloat newYCenter = MAX(MIN(self.expandedCenterValue.y, newYOffset), self.expandedCenterValue.y - self.contractionAmountValue);
    
    self.view.center = CGPointMake(self.expandedCenterValue.x, newYCenter);
    
    CGFloat newAlpha = 1.f - (self.expandedCenterValue.y - self.view.center.y) / self.contractionAmountValue;
    newAlpha = MIN(MAX(FLT_EPSILON, newAlpha), 1.f);
    
    [self _updateSubviewsToAlpha:newAlpha];
    
    CGFloat residual = newYOffset - newYCenter;
    return residual;
}

- (CGFloat)snap:(BOOL)contract
{
    CGFloat deltaY = (contract
                      ? self.expandedCenterValue.y - self.view.center.y
                      : self.expandedCenterValue.y - self.contractionAmountValue);
    
    return [self updateYOffset:deltaY];
}

- (void)expand
{
    self.view.center = self.expandedCenter(self.view);
}

- (void)contract
{
    
}

@end
