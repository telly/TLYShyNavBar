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

static const CGFloat contractionVelocity = 140.f;

@interface TLYShyNavBarController () <UIGestureRecognizerDelegate>

@property (nonatomic, readonly) UINavigationBar *navBar;

@property (nonatomic, readonly) CGPoint expandedNavBarCenter;
@property (nonatomic, readonly) CGPoint expandedExtensionCenter;

@property (nonatomic, readonly) CGFloat navBarContractionAmount;
@property (nonatomic, readonly) CGFloat extensionContractionAmount;

@property (nonatomic) CGFloat previousYOffset;

@property (nonatomic, getter = isContracting) BOOL isContracting;

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
    [_extensionView removeFromSuperview];
    _extensionView = extensionView;

    CGRect frame = extensionView.frame;
    frame.origin.y = CGRectGetMaxY(self.navBar.frame);
    
    extensionView.frame = frame;
    
    [self.navBar.superview insertSubview:extensionView belowSubview:self.navBar];
    
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.top = CGRectGetHeight(frame) + self.viewController.topLayoutGuide.length;
    
    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
}


- (void)setViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    
    /* force reload extensionView */
    self.extensionView = self.extensionView;
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

- (CGPoint)expandedNavBarCenter
{
    return CGPointMake(CGRectGetMidX(self.navBar.bounds),
                       CGRectGetMidY(self.navBar.bounds) + AACStatusBarHeight());
}

- (CGPoint)expandedExtensionCenter
{
    return CGPointMake(CGRectGetMidX(self.extensionView.bounds),
                       CGRectGetMidY(self.extensionView.bounds) + CGRectGetMaxY(self.navBar.frame));
}

#pragma mark - Private methods

- (CGFloat)navBarContractionAmount
{
    return CGRectGetHeight(self.navBar.bounds);
}

- (CGFloat)extensionContractionAmount
{
    return CGRectGetHeight(self.extensionView.bounds);
}

- (CGFloat)_snapView:(UIView *)view withExpandedCenter:(CGPoint)expandedCenter contractionAmount:(CGFloat)contraction
{
    CGFloat newCenterY = (self.isContracting
                          ? expandedCenter.y - contraction
                          : expandedCenter.y);
    
    return [self _updateView:view toYOffset:newCenterY];
}

- (CGFloat)_updateView:(UIView *)view toYOffset:(CGFloat)yOffset
{
    CGFloat deltaY = yOffset - view.center.y;
    BOOL isContracting = deltaY < 0;
    
    [UIView animateWithDuration:fabs(deltaY/contractionVelocity)
                     animations:^{
                         view.center = CGPointMake(view.center.x, yOffset);
                         [self _updateViews:view.subviews toAlpha:isContracting ? FLT_EPSILON : 1.f];
                     }];
    
    return deltaY;
}

- (CGFloat)_updateExtensionViewWithDeltaY:(CGFloat)deltaY
{
    return [self _updateView:self.extensionView withDeltaY:deltaY expandedCenter:self.expandedExtensionCenter contractionAmount:self.extensionContractionAmount];
}

- (CGFloat)_updateNavigationBarWithDeltaY:(CGFloat)deltaY
{
    return [self _updateView:self.navBar withDeltaY:deltaY expandedCenter:self.expandedNavBarCenter contractionAmount:self.navBarContractionAmount];
}

- (CGFloat)_updateView:(UIView *)view withDeltaY:(CGFloat)deltaY expandedCenter:(CGPoint)expandedCenter contractionAmount:(CGFloat)contraction
{
    CGFloat newYOffset = view.center.y - deltaY;
    CGFloat newYCenter = MAX(MIN(expandedCenter.y, newYOffset), expandedCenter.y - contraction);
    
    view.center = CGPointMake(expandedCenter.x, newYCenter);;
    
    CGFloat newAlpha = 1.f - (self.expandedNavBarCenter.y - view.center.y) / contraction;
    newAlpha = MIN(MAX(FLT_EPSILON, newAlpha), 1.f);
    
    [self _updateViews:view.subviews toAlpha:newAlpha];
    
    CGFloat residualDelta = MIN(MAX(0, newYOffset - expandedCenter.y),
                                newYOffset - expandedCenter.y + contraction);
    
    return -residualDelta;
}

// This method is courtesy of GTScrollNavigationBar
// https://github.com/luugiathuy/GTScrollNavigationBar
- (void)_updateViews:(NSArray *)views toAlpha:(CGFloat)alpha
{
    for (UIView* view in views)
    {
        bool isBackgroundView = view == self.navBar.subviews[0];
        bool isViewHidden = view.hidden || view.alpha < FLT_EPSILON;
        
        if (!isBackgroundView && !isViewHidden)
        {
            view.alpha = alpha;
        }
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
        
        self.isContracting = deltaY > 0;
        
        if (deltaY > 0)
        {
            deltaY = [self _updateExtensionViewWithDeltaY:deltaY];
            [self _updateNavigationBarWithDeltaY:deltaY];
        }
        else
        {
            deltaY = [self _updateNavigationBarWithDeltaY:deltaY];
            [self _updateExtensionViewWithDeltaY:deltaY];
        }
    }
    
    self.previousYOffset = self.scrollView.contentOffset.y;
}

- (void)_handleScrollingEnded
{
    CGFloat deltaY = [self _snapView:self.extensionView withExpandedCenter:self.expandedExtensionCenter contractionAmount:self.extensionContractionAmount];
    deltaY += [self _snapView:self.navBar withExpandedCenter:self.expandedNavBarCenter contractionAmount:self.navBarContractionAmount];
    
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

