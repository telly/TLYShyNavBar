//
//  TLYOffsetShyController.m
//  Telly
//
//  Created by Mazyad Alabduljaleel on 10/28/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYOffsetShyController.h"

@interface TLYOffsetShyController ()

@property (nonatomic) CGPoint expandedCenterValue;
@property (nonatomic) CGFloat contractionAmountValue;

@property (nonatomic) CGPoint contractedCenterValue;

@end

@implementation TLYOffsetShyController

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

- (CGFloat)phase
{
    CGFloat phase = 1.f - (self.expandedCenterValue.y - self.view.center.y) / self.contractionAmountValue;
    return MIN(MAX(0.f, phase), 1.f);
}

- (CGFloat)totalHeight
{
    return self.child.totalHeight + (self.expandedCenterValue.y - self.contractedCenterValue.y);
}

#pragma mark - Public methods

- (void)updateSubviewsToAlpha:(CGFloat)alpha
{
    if ([self.view respondsToSelector:@selector(updateSubviewsToAlpha:)])
    {
        [(id)self.view updateSubviewsToAlpha:alpha];
    }
    else
    {
        self.view.alpha = alpha;
    }
}

- (CGFloat)performUpdateForDelta:(CGFloat)deltaY
{
    CGFloat newYOffset = self.view.center.y + deltaY;
    CGFloat newYCenter = MAX(MIN(self.expandedCenterValue.y, newYOffset), self.contractedCenterValue.y);
    
    self.view.center = CGPointMake(self.expandedCenterValue.x, newYCenter);
    
    CGFloat residual = newYOffset - newYCenter;
    
    return residual;
}

- (CGFloat)expand
{
    self.view.hidden = NO;
    
    if (self.hidesSubviews && self.alphaFadeEnabled)
    {
        [self updateSubviewsToAlpha:1.f];
    }
    
    CGFloat amountToMove = self.expandedCenterValue.y - self.view.center.y;
    
    self.view.center = self.expandedCenterValue;
    [self.child expand];
    
#warning HACK - one more hack :(
    if ([self.view isKindOfClass:[UINavigationBar class]]) {
        CGRect newFrame = self.view.frame;
        newFrame.size.height = MAX(44.f, newFrame.size.height);
        
        self.view.frame = newFrame;
    }
    
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
