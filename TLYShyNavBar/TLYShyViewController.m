//
//  TLYShyViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/14/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyViewController.h"


@implementation TLYShyViewController (AsParent)

- (CGFloat)viewMaxY
{
    return CGRectGetMaxY(self.view.frame);
}

- (CGFloat)calculateTotalHeightRecursively
{
    return CGRectGetHeight(self.view.bounds) + [self.parent calculateTotalHeightRecursively];
}

@end


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
    CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                 CGRectGetMidY(self.view.bounds));
    
    center.y += self.parent.viewMaxY;
    
    return center;
}

- (CGFloat)contractionAmountValue
{
    return self.sticky ? 0.f : CGRectGetHeight(self.view.bounds);
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

- (void)_onAlphaUpdate:(CGFloat)alpha
{
    if (self.sticky)
    {
        self.view.alpha = 1.f;
        [self _updateSubviewsAlpha:1.f];
        return;
    }
    
    switch (self.fadeBehavior) {
            
        case TLYShyNavViewControllerFadeDisabled:
            self.view.alpha = 1.f;
            [self _updateSubviewsAlpha:1.f];
            break;
            
        case TLYShyNavViewControllerFadeSubviews:
            self.view.alpha = 1.f;
            [self _updateSubviewsAlpha:alpha];
            break;
            
        case TLYShyNavViewControllerFadeNavbar:
            self.view.alpha = alpha;
            [self _updateSubviewsAlpha:1.f];
            break;
    }
}

// This method is courtesy of GTScrollNavigationBar
// https://github.com/luugiathuy/GTScrollNavigationBar
- (void)_updateSubviewsAlpha:(CGFloat)alpha
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

- (void)_updateCenter:(CGPoint)newCenter
{
    CGPoint currentCenter = self.view.center;
    CGPoint deltaPoint = CGPointMake(newCenter.x - currentCenter.x,
                                     newCenter.y - currentCenter.y);
    
    [self offsetCenterBy:deltaPoint];
}

#pragma mark - Public methods

- (void)setFadeBehavior:(TLYShyNavViewControllerFade)fadeBehavior
{
    _fadeBehavior = fadeBehavior;
    
    if (fadeBehavior == TLYShyNavViewControllerFadeDisabled)
    {
        [self _onAlphaUpdate:1.f];
    }
}

- (void)offsetCenterBy:(CGPoint)deltaPoint
{
    [self.child offsetCenterBy:deltaPoint];
    
    self.view.center = CGPointMake(self.view.center.x + deltaPoint.x,
                                   self.view.center.y + deltaPoint.y);
}

- (CGFloat)updateYOffset:(CGFloat)deltaY
{    
    if (self.child && deltaY < 0)
    {
        deltaY = [self.child updateYOffset:deltaY];
        self.child.view.hidden = (!self.child.sticky && deltaY < 0);
    }
    
    CGFloat newYOffset = self.view.center.y + deltaY;
    CGFloat newYCenter = MAX(MIN(self.expandedCenterValue.y, newYOffset), self.contractedCenterValue.y);
    
    [self _updateCenter:CGPointMake(self.expandedCenterValue.x, newYCenter)];
    
    CGFloat newAlpha = 1.f - (self.expandedCenterValue.y - self.view.center.y) / self.contractionAmountValue;
    newAlpha = MIN(MAX(FLT_EPSILON, newAlpha), 1.f);
    
    [self _onAlphaUpdate:newAlpha];
    
    CGFloat residual = newYOffset - newYCenter;
    
    if (self.child && deltaY > 0 && residual > 0)
    {
        residual = [self.child updateYOffset:residual];
        self.child.view.hidden = (!self.child.sticky && residual - (newYOffset - newYCenter) > FLT_EPSILON);
    }
    else if (self.child.sticky && deltaY > 0)
    {
        [self.child updateYOffset:deltaY];
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
    
    [self _onAlphaUpdate:1.f];
    
    CGFloat amountToMove = self.expandedCenterValue.y - self.view.center.y;

    [self _updateCenter:self.expandedCenterValue];
    [self.child expand];
    
    return amountToMove;
}

- (CGFloat)contract
{
    CGFloat amountToMove = self.contractedCenterValue.y - self.view.center.y;

    [self _updateCenter:self.contractedCenterValue];
    [self.child contract];
    
    return amountToMove;
}

@end
