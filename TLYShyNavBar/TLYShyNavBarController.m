//
//  TLYShyNavBarController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/13/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyNavBarController.h"
#import <objc/runtime.h>

// Thanks to SO user, MattDiPasquale
// http://stackoverflow.com/questions/12991935/how-to-programmatically-get-ios-status-bar-height/16598350#16598350

static inline CGFloat AACStatusBarHeight()
{
    CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    return MIN(statusBarSize.width, statusBarSize.height);
}


@interface TLYShyNavBarController () <UIGestureRecognizerDelegate>

@property (nonatomic, readonly) UINavigationBar *navBar;

/* BAD: This is a cached value. Test when there is an active call, and try to compute this */
@property (nonatomic) CGPoint initialNavBarCenter;
@property (nonatomic) CGFloat previousYOffset;

@property (nonatomic, getter = isContracting) BOOL contracting;

@end

@implementation TLYShyNavBarController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.previousYOffset = NAN;
    }
    return self;
}

- (void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - Properties

- (void)setExtensionView:(UIView *)extensionView
{
    if (_extensionView.superview == self.viewController.navigationController.view)
    {
        [_extensionView removeFromSuperview];
    }
    
    _extensionView = extensionView;

    CGRect frame = extensionView.frame;
    frame.origin.y = CGRectGetMaxY(self.navBar.frame);
    
    extensionView.frame = frame;
    
    [self.viewController.navigationController.view addSubview:extensionView];
}


- (void)setViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    
    self.initialNavBarCenter = self.navBar.center;
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    _scrollView = scrollView;
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:NULL];
}

- (UINavigationBar *)navBar
{
    return self.viewController.navigationController.navigationBar;
}

#pragma mark - Private methods

- (CGFloat)_contractionAmount
{
    return CGRectGetHeight(self.navBar.bounds);
}

- (CGFloat)_updateNavigationBarToState:(BOOL)contract
{
    static const CGFloat velocity = 140.f;
    
    CGFloat newCenterY = (contract
                          ? self.initialNavBarCenter.y - [self _contractionAmount]
                          : self.initialNavBarCenter.y);
    
    CGFloat deltaY = newCenterY - self.navBar.center.y;
    
    [UIView animateWithDuration:fabs(deltaY/velocity)
                     animations:^{
                         self.navBar.center = CGPointMake(self.navBar.center.x, newCenterY);
                         [self _updateSubviewsAlpha:self.isContracting ? FLT_EPSILON : 1.f];
                     }];
    
    return deltaY;
}

- (void)_updateNavigationBarWithDeltaY:(CGFloat)deltaY
{
    CGPoint newCenter = self.navBar.center;
    newCenter.y = MAX(MIN(self.initialNavBarCenter.y, newCenter.y - deltaY),
                      self.initialNavBarCenter.y - [self _contractionAmount]);
    
    self.navBar.center = newCenter;
    
    CGFloat newAlpha = 1.f - (self.initialNavBarCenter.y - newCenter.y) / [self _contractionAmount];
    newAlpha = MIN(MAX(FLT_EPSILON, newAlpha), 1.f);
    
    NSMutableArray *navItems = [NSMutableArray array];
    [navItems addObjectsFromArray:self.viewController.navigationItem.leftBarButtonItems];
    [navItems addObjectsFromArray:self.viewController.navigationItem.rightBarButtonItems];
    
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

- (void)_handleScrolling
{
    if (!isnan(self.previousYOffset))
    {
        CGFloat deltaY = (self.scrollView.contentOffset.y - self.previousYOffset);
        CGFloat offset;
        
        offset = -self.scrollView.contentInset.top;
        if (self.scrollView.contentOffset.y - deltaY < offset)
        {
            deltaY = MAX(0, self.scrollView.contentOffset.y - deltaY + offset);
        }
        
        /* rounding to resolve a dumb issue with the contentOffset value */
        offset = floorf(self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds) - self.scrollView.contentInset.bottom - 0.5f);
        if (self.scrollView.contentOffset.y + deltaY > offset)
        {
            deltaY = MAX(0, self.scrollView.contentOffset.y + deltaY + offset);
        }
        
        [self _updateNavigationBarWithDeltaY:deltaY];
    }
    
    self.previousYOffset = self.scrollView.contentOffset.y;
}

- (void)_handleScrollingEnded
{
    CGFloat deltaY = [self _updateNavigationBarToState:self.isContracting];
    
    CGPoint newContentOffset = self.scrollView.contentOffset;
    newContentOffset.y -= deltaY;
    
    // TODO: manually animate content offset to match navbar animation
    [self.scrollView setContentOffset:newContentOffset animated:YES];
}

- (void)scrollViewDidEndScrolling
{
    [self _handleScrollingEnded];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:NSStringFromSelector(@selector(contentOffset))])
    {
        [self _handleScrolling];
    }
}

@end


static char shyNavBarControllerKey;

@implementation UIViewController (ShyNavBar)

- (void)setShyNavBarController:(TLYShyNavBarController *)shyNavBarController
{
    shyNavBarController.viewController = self;
    objc_setAssociatedObject(self, &shyNavBarControllerKey, shyNavBarController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TLYShyNavBarController *)shyNavBarController
{
    return objc_getAssociatedObject(self, &shyNavBarControllerKey);
}

@end

