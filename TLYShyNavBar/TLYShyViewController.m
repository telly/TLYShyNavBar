//
//  TLYShyViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/14/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyViewController.h"

const CGFloat contractionVelocity = 300.f;

@interface TLYShyViewController ()

@property (nonatomic) CGPoint expandedCenterValue;
@property (nonatomic) CGFloat contractionAmountValue;

@property (nonatomic) CGPoint contractedCenterValue;

@property (nonatomic, getter = isContracted) BOOL contracted;
@property (nonatomic, getter = isExpanded) BOOL expanded;

@end

@implementation TLYShyViewController

#pragma mark - Properties

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

- (BOOL)isContracted
{
    return fabs(self.view.center.y - self.contractedCenterValue.y) < FLT_EPSILON;
}

- (BOOL)isExpanded
{
    return fabs(self.view.center.y - self.expandedCenterValue.y) < FLT_EPSILON;
}

- (CGFloat)totalHeight
{
    return self.child.totalHeight + (self.expandedCenterValue.y - self.contractedCenterValue.y);
}

#pragma mark - Private methods

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

#pragma mark - Public methods

- (void)setAlphaFadeEnabled:(BOOL)alphaFadeEnabled
{
    _alphaFadeEnabled = alphaFadeEnabled;
    
    if (!alphaFadeEnabled)
    {
        [self _updateSubviewsToAlpha:1.f];
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
        
        if (self.alphaFadeEnabled)
        {
            [self _updateSubviewsToAlpha:newAlpha];
        }
    }
    
    CGFloat residual = newYOffset - newYCenter;
    
    if (self.child && deltaY > 0 && residual > 0)
    {
        residual = [self.child updateYOffset:residual];
        self.child.view.hidden = residual - (newYOffset - newYCenter) > 0;
    }
    
    return residual;
}

- (CGFloat)snap:(BOOL)contract
{
    /* "The Facebook" UX dictates that:
     *
     *      1 - When you contract:
     *          A - contract beyond the extension view -> contract the whole thing
     *          B - contract within the extension view -> expand the extension back
     *
     *      2 - When you expand:
     *          A - expand beyond the navbar -> expand the whole thing
     *          B - expand within the navbar -> contract the navbar back
     */
    
    __block CGFloat deltaY;
    [UIView animateWithDuration:0.2 animations:^
    {
        if ((contract && self.child.isContracted) || (!contract && !self.isExpanded))
        {
            deltaY = [self contract];
        }
        else
        {
            deltaY = [self.child expand];
        }
    }];
    
    return deltaY;
}

- (CGFloat)expand
{
    self.view.hidden = NO;
    
    if (self.hidesSubviews && self.alphaFadeEnabled)
    {
        [self _updateSubviewsToAlpha:1.f];
    }
    
    CGFloat amountToMove = self.expandedCenterValue.y - self.view.center.y;

    self.view.center = self.expandedCenterValue;
    [self.child expand];
    
    return amountToMove;
}

- (CGFloat)contract
{
    CGFloat amountToMove = self.contractedCenterValue.y - self.view.center.y;

    self.view.center = self.contractedCenterValue;
    [self.child contract];
    
    return amountToMove;
}

@end
