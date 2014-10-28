//
//  TLYBoundsShyController.m
//  Telly
//
//  Created by Mazyad Alabduljaleel on 10/28/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYBoundsShyController.h"
#import "TLYShyNavBarManager.h"

@interface TLYBoundsShyController ()

@property (nonatomic, readonly) CGFloat initialViewHeight;

@end

@implementation TLYBoundsShyController

#pragma mark - Properties

- (BOOL)isExpanded
{
    return fabs(CGRectGetHeight(self.view.bounds) - self.initialViewHeight) < FLT_EPSILON;
}

- (BOOL)isContracted
{
    return fabs(CGRectGetHeight(self.view.bounds) - self.initialViewHeight - self.navbarHeight) < FLT_EPSILON;
}

- (CGFloat)initialViewHeight
{
    // Very bad assumption, but I know no other way :(
    return (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
            ? CGRectGetWidth([UIScreen mainScreen].bounds)
            : CGRectGetHeight([UIScreen mainScreen].bounds));
}

- (CGFloat)phase
{
    CGFloat phase = 1.f - (CGRectGetHeight(self.view.bounds) - self.initialViewHeight) / self.navbarHeight;
    return MIN(MAX(0.f, phase), 1.f);
}

- (CGFloat)totalHeight
{
    return self.navbarHeight + self.child.totalHeight;
}

- (CGFloat)navbarHeight
{
    return CGRectGetHeight(self.navbarBlock().bounds);
}

#pragma mark - Public methods

// This method is courtesy of GTScrollNavigationBar
// https://github.com/luugiathuy/GTScrollNavigationBar
- (void)updateSubviewsToAlpha:(CGFloat)alpha
{
    UIView *navbar = self.navbarBlock();
    for (UIView* view in navbar.subviews)
    {
        bool isBackgroundView = view == [navbar.subviews firstObject];
        bool isViewHidden = view.hidden || view.alpha < FLT_EPSILON;
        
        if (!isBackgroundView && !isViewHidden)
        {
            view.alpha = MAX(alpha, FLT_EPSILON);
        }
    }
}

- (CGFloat)performUpdateForDelta:(CGFloat)deltaY
{
    CGFloat heightDelta = CGRectGetHeight(self.view.bounds) - self.initialViewHeight;
    
    CGFloat newDelta = MIN(heightDelta, MAX(heightDelta - self.navbarHeight, deltaY));
    CGRect navFrame = UIEdgeInsetsInsetRect(self.view.frame, UIEdgeInsetsMake(newDelta, 0, 0, 0));
    
    self.cancelScrollBlock(newDelta);
    self.view.frame = navFrame;
        
    CGFloat residual = deltaY - newDelta;
    
    return residual;
}

- (CGFloat)expand
{
    [super expand];
    
    /* To "expand" the nav bar, we shrink the nav view */
    CGFloat amountToShrink = CGRectGetHeight(self.view.bounds) - self.initialViewHeight;
    self.view.frame = UIEdgeInsetsInsetRect(self.view.frame, UIEdgeInsetsMake(amountToShrink, 0, 0, 0));
    
    return amountToShrink;
}

- (CGFloat)contract
{
    [super contract];
    
    /* to "contract" the nav bar, we expand the nav view */
    CGFloat amountToExpand = CGRectGetHeight(self.view.bounds) - self.initialViewHeight - self.navbarHeight;
    self.view.frame = UIEdgeInsetsInsetRect(self.view.frame, UIEdgeInsetsMake(amountToExpand, 0, 0, 0));
    
    return amountToExpand;
}

@end
