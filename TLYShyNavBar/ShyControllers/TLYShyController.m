//
//  TLYShyController.m
//  Telly
//
//  Created by Mazyad Alabduljaleel on 10/28/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyController.h"

const CGFloat contractionVelocity = 300.f;

@implementation TLYShyController

#pragma mark - Properties

- (BOOL)isContracted
{
    [self _throwAbstractMethodException];
    return NO;
}

- (BOOL)isExpanded
{
    [self _throwAbstractMethodException];
    return NO;
}

- (CGFloat)totalHeight
{
    [self _throwAbstractMethodException];
    return 0xBAD;
}

#pragma mark - Private methods

- (void)updateSubviewsToAlpha:(CGFloat)alpha
{
    [self _throwAbstractMethodException];
}

- (void)_throwAbstractMethodException
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Abstract method not implemented"
                                 userInfo:nil];
}

#pragma mark - Public methods

- (void)setAlphaFadeEnabled:(BOOL)alphaFadeEnabled
{
    _alphaFadeEnabled = alphaFadeEnabled;
    
    if (!alphaFadeEnabled)
    {
        [self updateSubviewsToAlpha:1.f];
    }
}

- (CGFloat)performUpdateForDelta:(CGFloat)deltaY
{
    [self _throwAbstractMethodException];
    return 0.f;
}

- (CGFloat)updateYOffset:(CGFloat)deltaY
{
    if (self.child && deltaY < 0)
    {
        deltaY = [self.child updateYOffset:deltaY];
        self.child.view.hidden = deltaY < 0.f;
    }
    
    CGFloat residual = [self performUpdateForDelta:deltaY];
    
    if (self.hidesSubviews)
    {
        if (self.alphaFadeEnabled)
        {
            [self updateSubviewsToAlpha:self.phase];
        }
    }
    
    if (self.child && deltaY > 0 && residual > 0)
    {
        residual = [self.child updateYOffset:residual];
        self.child.view.hidden = residual < 0;
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
    return [self.child expand];
}

- (CGFloat)contract
{
    return [self.child contract];
}

@end

