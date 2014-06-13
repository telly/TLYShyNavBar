//
//  UIViewController+ShyNavBar.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/12/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "UIViewController+ShyNavBar.h"
#import "TLYViewController.h"
#import <objc/runtime.h>

static char initialNavBarCenterKey;
static char previousYOffsetKey;
static char draggingKey;
static char contractingKey;

static const CGFloat contractionAmount = 44.f;

@interface UIViewController ()

@property (nonatomic, readonly) UINavigationBar *navBar;

@property (nonatomic) CGPoint initialNavBarCenter;
@property (nonatomic) CGFloat previousYOffset;

@property (nonatomic, getter = isDragging) BOOL dragging;
@property (nonatomic, getter = isContracting) BOOL contracting;

@end

@implementation UIViewController (ShyNavBar)

#pragma mark - Category properties

- (UINavigationBar *)navBar
{
    return self.navigationController.navigationBar;
}

- (void)setInitialNavBarCenter:(CGPoint)initialNavBarCenter
{
    objc_setAssociatedObject(self, &initialNavBarCenterKey, [NSValue valueWithCGPoint:initialNavBarCenter], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)initialNavBarCenter
{
    id value = objc_getAssociatedObject(self, &initialNavBarCenterKey);
    CGPoint center = [value CGPointValue];
    if (!value)
    {
        center = self.navigationController.navigationBar.center;
        self.initialNavBarCenter = center;
    }
    
    return center;
}

- (void)setPreviousYOffset:(CGFloat)previousYOffset
{
    objc_setAssociatedObject(self, &previousYOffsetKey, @(previousYOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)previousYOffset
{
    id number = objc_getAssociatedObject(self, &previousYOffsetKey);
    return number ? [number floatValue] : NAN;
}

- (void)setDragging:(BOOL)dragging
{
    objc_setAssociatedObject(self, &draggingKey, @(dragging), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isDragging
{
    return [objc_getAssociatedObject(self, &draggingKey) boolValue];
}

- (void)setContracting:(BOOL)contracting
{
    objc_setAssociatedObject(self, &contractingKey, @(contracting), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isContracting
{
    return [objc_getAssociatedObject(self, &contractingKey) boolValue];
}

#pragma mark - Private methods

- (void)_updateNavigationBarWithDeltaY:(CGFloat)deltaY
{
    CGPoint newCenter = self.navBar.center;
    newCenter.y = MAX(MIN(self.initialNavBarCenter.y, newCenter.y - deltaY),
                      self.initialNavBarCenter.y - contractionAmount);
    
    self.navBar.center = newCenter;
    
    CGFloat newAlpha = 1.f - (self.initialNavBarCenter.y - newCenter.y) / contractionAmount;
    newAlpha = MIN(MAX(FLT_EPSILON, newAlpha), 1.f);
    
    NSMutableArray *navItems = [NSMutableArray array];
    [navItems addObjectsFromArray:self.navigationItem.leftBarButtonItems];
    [navItems addObjectsFromArray:self.navigationItem.rightBarButtonItems];

    if (self.navBar.topItem.titleView)
    {
        [navItems addObject:self.navBar.topItem.titleView];
    }
    
    [self _updateSubviewsAlpha:newAlpha];
    
    self.contracting = deltaY > 0;
}

- (void)_updateSubviewsAlpha:(CGFloat)alpha
{
    for (UIView* view in self.navBar.subviews)
    {
        bool isBackgroundView = view == self.navBar.subviews[0];
        bool isViewHidden = view.hidden || view.alpha < FLT_EPSILON;
        
        if (isBackgroundView || isViewHidden)
            continue;
        
        view.alpha = alpha;
    }
}

#pragma mark - Public methods

- (void)tly_scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.dragging = YES;
}

- (void)tly_scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!isnan(self.previousYOffset))
    {
        CGFloat deltaY = scrollView.contentOffset.y - self.previousYOffset;
        CGFloat offset;
        
        offset = -scrollView.contentInset.top;
        if (scrollView.contentOffset.y - deltaY < offset)
        {
            deltaY = MAX(0, scrollView.contentOffset.y - deltaY + offset);
        }
        
        offset = scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds) - scrollView.contentInset.bottom;
        if (scrollView.contentOffset.y + deltaY > offset)
        {
            deltaY = MAX(0, scrollView.contentOffset.y + deltaY + offset);
        }
        
        [self _updateNavigationBarWithDeltaY:deltaY];
    }
    
    self.previousYOffset = scrollView.contentOffset.y;
}

- (void)tly_scrollViewDidEndDragging:(UIScrollView *)scrollView
{
    static const CGFloat velocity = 140.f;

    self.dragging = NO;
    
    CGFloat newCenterY = (self.isContracting
                          ? self.initialNavBarCenter.y - contractionAmount
                          : self.initialNavBarCenter.y);

    CGFloat deltaY = newCenterY - self.navBar.center.y;
    
    [UIView animateWithDuration:fabs(deltaY/velocity)
                     animations:^{
                         self.navBar.center = CGPointMake(self.navBar.center.x, newCenterY);
                         [self _updateSubviewsAlpha:self.isContracting ? FLT_EPSILON : 1.f];
                     }];
    
    CGPoint newContentOffset = scrollView.contentOffset;
    newContentOffset.y -= deltaY;
    
    // TODO: manually animate content offset to match navbar animation
    [scrollView setContentOffset:newContentOffset animated:YES];
}

@end
