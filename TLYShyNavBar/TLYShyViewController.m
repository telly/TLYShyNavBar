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

@property (nonatomic, weak) TLYShyViewController *parent;
@property (nonatomic, readonly) CGFloat parentYOffset;

@property (nonatomic) CGPoint expandedCenterValue;
@property (nonatomic) CGFloat contractionAmountValue;

@property (nonatomic) CGPoint contractedCenterValue;

@end

@implementation TLYShyViewController

- (void)setChild:(TLYShyViewController *)child
{
    _child.parent = nil;
    _child = child;
    _child.parent = self;
}

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

- (CGFloat)parentYOffset
{
    CGFloat parentOffset = 0;
    if (self.parent)
    {
        parentOffset = MIN(0, self.parent.view.center.y - self.parent.expandedCenterValue.y);
    }
    
    return parentOffset;
}

- (void)_updateSubviewsToAlpha:(CGFloat)alpha
{
    for (UIView* view in self.view.subviews)
    {
        NSString *className = NSStringFromClass([view class]);
        if (![className isEqualToString:@"_UINavigationBarBackground"] &&
            ![className isEqualToString:@"_UINavigationBarBackIndicatorView"])
        {
            view.alpha = alpha;
        }
    }
}

- (CGFloat)_updateYOffsetInternal:(CGFloat)deltaY
{
    CGFloat newYOffset = self.view.center.y + deltaY - self.parentYOffset;
    CGFloat newYCenter = MAX(MIN(self.expandedCenterValue.y, newYOffset), self.contractedCenterValue.y);
    
    CGFloat residual = newYOffset - newYCenter;
    
    if (self.parent && deltaY < 0)
    {
        residual = [self.parent _updateYOffsetInternal:residual];
    }
    else if (self.child && deltaY > 0)
    {
        residual = [self.child _updateYOffsetInternal:residual];
    }
    
    self.view.center = CGPointMake(self.expandedCenterValue.x, newYCenter + self.parentYOffset);
    
    if (self.hidesSubviews)
    {
        CGFloat newAlpha = 1.f - (self.expandedCenterValue.y - self.view.center.y) / self.contractionAmountValue;
        newAlpha = MIN(MAX(FLT_EPSILON, newAlpha), 1.f);
        
        [self _updateSubviewsToAlpha:newAlpha];
    }
    
    return residual;
}

- (CGFloat)updateYOffset:(CGFloat)deltaY
{
    if (self.child && deltaY < 0)
    {
        return [self.child updateYOffset:deltaY];
    }
    else
    {
        return [self _updateYOffsetInternal:deltaY];
    }
}

- (CGFloat)snap:(BOOL)contract afterDelay:(NSTimeInterval)delay
{
    CGFloat newYCenter = (contract
                          ? self.expandedCenterValue.y - self.contractionAmountValue
                          : self.expandedCenterValue.y);
    
    CGFloat deltaY = newYCenter - (self.view.center.y - self.parentYOffset);
    CGFloat duration = fabs(deltaY/contractionVelocity);
    
    if (contract)
    {
        CGFloat childDelta = [self.child snap:contract afterDelay:delay];
        delay += fabs(childDelta/contractionVelocity);
        
        deltaY += childDelta;
    }
    else
    {
        deltaY += [self.child snap:contract afterDelay:delay+duration];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        NSLog(@"delay: %.4f", delay);
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [self updateYOffset:deltaY];
                         } completion:nil];
    });
    
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
