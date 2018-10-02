//
//  TLYShyViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/14/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyViewController.h"
#import "TLYShyStatusBarController.h"


@implementation TLYShyViewController (AsParent)

- (CGFloat)maxYRelativeToView:(UIView *)superview
{
    CGPoint maxEdge = CGPointMake(0, CGRectGetHeight(self.view.bounds));
    CGPoint normalizedMaxEdge = [superview convertPoint:maxEdge fromView:self.view];
    
    return normalizedMaxEdge.y;
}

- (CGFloat)calculateTotalHeightRecursively
{
    return (self.expanded ? CGRectGetHeight(self.view.bounds) : 0) + [self.parent calculateTotalHeightRecursively];
}

@end


@interface TLYShyViewController ()

@property (nonatomic, assign) CGPoint expandedCenterValue;
@property (nonatomic, assign) CGFloat contractionAmountValue;

@property (nonatomic, assign) CGPoint contractedCenterValue;

@end

@implementation TLYShyViewController

#pragma mark - Properties

// convenience
- (CGPoint)expandedCenterValue
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                 CGRectGetMidY(self.view.bounds));
    
    center.y += [self.parent maxYRelativeToView:self.view.superview];
    
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

- (BOOL)contracted
{
    return fabs(self.view.center.y - self.contractedCenterValue.y) < FLT_EPSILON;
}

- (BOOL)expanded
{
    return fabs(self.view.center.y - self.expandedCenterValue.y) < FLT_EPSILON;
}

#pragma mark - Private methods

- (void)_onProgressUpdate:(CGFloat)progress
{
    [self _onAlphaUpdate:progress];
    [self _onScaleUpdate:progress];
}

- (void)_onAlphaUpdate:(CGFloat)alpha
{
    if (self.sticky)
    {
        self.view.alpha = 1.f;
        [self _updateSubviewsAlpha:1.f];
        return;
    }
    
    switch (self.fadeBehavior) {
            
        case TLYShyNavBarFadeDisabled:
            self.view.alpha = 1.f;
            [self _updateSubviewsAlpha:1.f];
            break;
            
        case TLYShyNavBarFadeSubviews:
            self.view.alpha = 1.f;
            [self _updateSubviewsAlpha:alpha];
            break;
            
        case TLYShyNavBarFadeNavbar:
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

- (void)_onScaleUpdate:(CGFloat)scale
{
    if (self.sticky)
    {
        [self _updateSubviewsScale:1.f];
        return;
    }
    
    [self _updateSubviewsScale:self.scale ? scale : 1.f];
}

- (void)_updateSubviewsScale:(CGFloat)scale
{
    if (![self.view isKindOfClass:[UINavigationBar class]])
    {
        return;
    }
    
    UINavigationBar *navigationBar = (UINavigationBar *)self.view;
    
    for (UIView* view in navigationBar.topItem.titleView.subviews)
    {
        view.transform = scale < 1 ? CGAffineTransformMakeScale(scale, scale) : CGAffineTransformIdentity;
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

- (void)setFadeBehavior:(TLYShyNavBarFade)fadeBehavior
{
    _fadeBehavior = fadeBehavior;
    
    if (fadeBehavior == TLYShyNavBarFadeDisabled)
    {
        [self _onAlphaUpdate:1.f];
    }
}

- (void)setScale:(BOOL)scale
{
    _scale = scale;
    
    if (!scale)
    {
        [self _onScaleUpdate:1.f];
    }
}

- (void)offsetCenterBy:(CGPoint)deltaPoint
{
    self.view.center = CGPointMake(self.view.center.x + deltaPoint.x,
                                   self.view.center.y + deltaPoint.y);
    
    [self.child offsetCenterBy:deltaPoint];
}

- (CGFloat)updateYOffset:(CGFloat)deltaY
{    
    if (self.subShyController && deltaY < 0)
    {
        deltaY = [self.subShyController updateYOffset:deltaY];
    }
    
    CGFloat residual = deltaY;
    
    if (!self.sticky)
    {
        CGFloat newYOffset = self.view.center.y + deltaY;
        CGFloat newYCenter = MAX(MIN(self.expandedCenterValue.y, newYOffset), self.contractedCenterValue.y);
        
        [self _updateCenter:CGPointMake(self.expandedCenterValue.x, newYCenter)];
        
        CGFloat newAlpha = 1.f - (self.expandedCenterValue.y - self.view.center.y) / self.contractionAmountValue;
        newAlpha = MIN(MAX(FLT_EPSILON, newAlpha), 1.f);
        
        [self _onProgressUpdate:newAlpha];
        
        residual = newYOffset - newYCenter;
        
        // QUICK FIX: Only the extensionView is hidden
        if (!self.subShyController)
        {
            self.view.hidden = residual < 0;
        }
    }
    
    if (self.subShyController && deltaY > 0 && residual > 0)
    {
        residual = [self.subShyController updateYOffset:residual];
    }
    
    return residual;
}

- (CGFloat)snap:(BOOL)contract
{
    return [self snap:contract completion:nil];
}

- (CGFloat)snap:(BOOL)contract completion:(void (^)())completion
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
        if ((contract && self.subShyController.contracted) || (!contract && !self.expanded))
        {
            deltaY = [self contract];
        }
        else
        {
            deltaY = [self.subShyController expand];
        }
    }
                     completion:^(BOOL finished)
    {
        if (completion && finished) {
            completion();
        }
    }];
    
    return deltaY;
}

- (CGFloat)expand
{
    self.view.hidden = NO;
    
    [self _onProgressUpdate:1.f];
    
    CGFloat amountToMove = self.expandedCenterValue.y - self.view.center.y;

    [self _updateCenter:self.expandedCenterValue];
    [self.subShyController expand];
    
    return amountToMove;
}

- (CGFloat)contract
{
    CGFloat amountToMove = self.contractedCenterValue.y - self.view.center.y;

    [self _onProgressUpdate:FLT_EPSILON];

    [self _updateCenter:self.contractedCenterValue];
    [self.subShyController contract];
    
    return amountToMove;
}

@end
