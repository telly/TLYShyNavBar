//
//  TLYShyNavBarManager.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/13/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyNavBarManager.h"
#import "TLYOffsetShyController.h"
#import "TLYBoundsShyController.h"
#import "TLYDelegateProxy.h"

#import "UIViewController+BetterLayoutGuides.h"
#import "NSObject+TLYSwizzlingHelpers.h"

#import <objc/runtime.h>

#pragma mark - Helper functions

// Thanks to SO user, MattDiPasquale
// http://stackoverflow.com/questions/12991935/how-to-programmatically-get-ios-status-bar-height/16598350#16598350

CGFloat tly_AACStatusBarHeight(void)
{
    if ([UIApplication sharedApplication].statusBarHidden)
    {
        return 0.f;
    }
    
    CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

#pragma mark - TLYShyNavBarManager class

@interface TLYShyNavBarManager () <UIScrollViewDelegate>

@property (nonatomic, unsafe_unretained) TLYShyController *navBarController;

@property (nonatomic, strong) TLYShyController *translucentNavBarController;
@property (nonatomic, strong) TLYShyController *opaqueNavBarController;
@property (nonatomic, strong) TLYShyController *extensionController;

@property (nonatomic, strong) TLYDelegateProxy *delegateProxy;

@property (nonatomic, strong) UIView *extensionViewContainer;

@property (nonatomic) CGFloat previousYOffset;
@property (nonatomic) CGFloat resistanceConsumed;

@property (nonatomic, getter = isContracting) BOOL contracting;
@property (nonatomic) BOOL previousContractionState;

@property (nonatomic, readonly) BOOL isViewControllerVisible;

@end

@implementation TLYShyNavBarManager

#pragma mark - Init & Dealloc

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.delegateProxy = [[TLYDelegateProxy alloc] initWithMiddleMan:self];
        
        self.contracting = NO;
        self.previousContractionState = YES;
        
        self.expansionResistance = 200.f;
        self.contractionResistance = 0.f;
        
        self.alphaFadeEnabled = YES;
        
        self.previousYOffset = NAN;
        
        __weak __typeof(self) weakSelf = self;

        self.opaqueNavBarController = ({
            TLYBoundsShyController *shyController = [[TLYBoundsShyController alloc] init];
            shyController.hidesSubviews = YES;
            shyController.cancelScrollBlock = ^(CGFloat deltaY)
            {
                UIScrollView *scrollView = weakSelf.scrollView;
                id delegate = scrollView.delegate;
                scrollView.delegate = nil;
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + deltaY);
                scrollView.delegate = (id)delegate;
            };
            
            shyController.navbarBlock = ^
            {
                return weakSelf.viewController.navigationController.navigationBar;
            };
            
            shyController;
        });
        
        self.translucentNavBarController = ({
            TLYOffsetShyController *shyController = [[TLYOffsetShyController alloc] init];
            shyController.hidesSubviews = YES;
            shyController.contractionAmount = ^(UIView *view)
            {
                return CGRectGetHeight(view.bounds);
            };
            
            shyController.expandedCenter = ^(UIView *view)
            {
                return CGPointMake(CGRectGetMidX(view.bounds),
                                   CGRectGetMidY(view.bounds) + tly_AACStatusBarHeight());
            };
            
            shyController;
        });
        
        self.extensionViewContainer = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100.f, 0.f)];
            view.backgroundColor = [UIColor clearColor];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
            view;
        });
        
        self.extensionController = ({
            TLYOffsetShyController *shyController = [[TLYOffsetShyController alloc] init];
            shyController.view = self.extensionViewContainer;
            shyController.hidesAfterContraction = YES;
            shyController.contractionAmount = ^(UIView *view)
            {
                return CGRectGetHeight(view.bounds);
            };
            
            shyController.expandedCenter = ^(UIView *view)
            {
                UIView *navbar = weakSelf.viewController.navigationController.navigationBar;
                return CGPointMake(CGRectGetMidX(view.bounds),
                                   CGRectGetMidY(view.bounds) + CGRectGetHeight(navbar.bounds) + tly_AACStatusBarHeight());
            };
            
            shyController;
        });
        
        self.navBarController.child = self.extensionController;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarFrame) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    // sanity check
    if (_scrollView.delegate == _delegateProxy)
    {
        _scrollView.delegate = _delegateProxy.originalDelegate;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Properties

- (void)setViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    
    UINavigationController *navController = viewController.navigationController;
    NSAssert(navController != nil, @"The view controller must already be in a navigation controller hierarchy");
    
    navController.automaticallyAdjustsScrollViewInsets = NO;
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.extensionViewContainer removeFromSuperview];
    [self.viewController.view addSubview:self.extensionViewContainer];
    
    if (navController.navigationBar.isTranslucent)
    {        
        self.navBarController = self.translucentNavBarController;
        self.navBarController.view = navController.navigationBar;
    }
    else
    {
        self.navBarController = self.opaqueNavBarController;
        self.navBarController.view = navController.view;
    }
    
    [self layoutViews];
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    if (_scrollView.delegate == self.delegateProxy)
    {
        _scrollView.delegate = self.delegateProxy.originalDelegate;
    }
    
    _scrollView = scrollView;
    
    if (_scrollView.delegate != self.delegateProxy)
    {
        self.delegateProxy.originalDelegate = _scrollView.delegate;
        _scrollView.delegate = (id)self.delegateProxy;
    }
    
    [self cleanup];
    [self layoutViews];
}

- (CGRect)extensionViewBounds
{
    return self.extensionViewContainer.bounds;
}

- (BOOL)isViewControllerVisible
{
    return self.viewController.isViewLoaded && self.viewController.view.window;
}

#pragma mark - Private methods

- (BOOL)_shouldHandleScrolling
{
    CGRect scrollFrame = UIEdgeInsetsInsetRect(self.scrollView.bounds, self.scrollView.contentInset);
    CGFloat scrollableAmount = self.scrollView.contentSize.height - CGRectGetHeight(scrollFrame);
    BOOL scrollViewIsSuffecientlyLong = (scrollableAmount > self.navBarController.totalHeight);
    
    return (self.isViewControllerVisible && scrollViewIsSuffecientlyLong);
}

- (void)_handleScrolling
{
    if (![self _shouldHandleScrolling])
    {
        return;
    }
    
    if (!isnan(self.previousYOffset))
    {
        [self layoutViews];
        
        // 1 - Calculate the delta
        CGFloat deltaY = (self.previousYOffset - self.scrollView.contentOffset.y);

        // 2 - Ignore any scrollOffset beyond the bounds
        CGFloat start = -self.scrollView.contentInset.top;
        if (self.previousYOffset < start)
        {
            deltaY = MIN(0, deltaY - self.previousYOffset - start);
        }
        
        /* rounding to resolve a dumb issue with the contentOffset value */
        CGFloat end = floorf(self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds) + self.scrollView.contentInset.bottom - 0.5f);
        if (self.previousYOffset > end)
        {
            deltaY = MAX(0, deltaY - self.previousYOffset + end);
        }
        
        // 3 - Update contracting variable
        if (fabs(deltaY) > FLT_EPSILON)
        {
            self.contracting = deltaY < 0;
        }
        
        // 4 - Check if contracting state changed, and do stuff if so
        if (self.isContracting != self.previousContractionState)
        {
            self.previousContractionState = self.isContracting;
            self.resistanceConsumed = 0;
        }

        // 5 - Apply resistance
        if (self.isContracting)
        {
            CGFloat availableResistance = self.contractionResistance - self.resistanceConsumed;
            self.resistanceConsumed = MIN(self.contractionResistance, self.resistanceConsumed - deltaY);

            deltaY = MIN(0, availableResistance + deltaY);
        }
        else if (self.scrollView.contentOffset.y > 0)
        {
            CGFloat availableResistance = self.expansionResistance - self.resistanceConsumed;
            self.resistanceConsumed = MIN(self.expansionResistance, self.resistanceConsumed + deltaY);
            
            deltaY = MAX(0, deltaY - availableResistance);
        }
        
        // 6 - Update the shyViewController
        self.navBarController.alphaFadeEnabled = self.alphaFadeEnabled;
        [self.navBarController updateYOffset:deltaY];
    }
    
    self.previousYOffset = self.scrollView.contentOffset.y;
}

- (void)_handleScrollingEnded
{
    if (!self.isViewControllerVisible)
    {
        return;
    }
    
    self.resistanceConsumed = 0;
    
    CGFloat deltaY = [self.navBarController snap:self.isContracting];
    CGPoint newContentOffset = self.scrollView.contentOffset;
    
    newContentOffset.y -= deltaY;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.scrollView.contentOffset = newContentOffset;
                     }];
}

#pragma mark - public methods

- (void)setExtensionView:(UIView *)view
{
    if (view != _extensionView)
    {
        [_extensionView removeFromSuperview];
        _extensionView = view;
        
        CGRect bounds = view.frame;
        bounds.origin = CGPointZero;
        
        view.frame = bounds;
        
        self.extensionViewContainer.frame = bounds;
        [self.extensionViewContainer addSubview:view];
        
        [self layoutViews];
    }
}

- (void)prepareForDisplay
{
    [self cleanup];
}

- (void)layoutViews
{
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.top = CGRectGetHeight(self.extensionViewContainer.bounds) + 64.f;
    
    if (UIEdgeInsetsEqualToEdgeInsets(scrollInsets, self.scrollView.contentInset))
    {
        return;
    }
    
    if (!self.scrollView.isTracking && !self.scrollView.isDragging && !self.scrollView.isDecelerating)
    {
        [self.navBarController expand];
    }
    
    [self.extensionViewContainer.superview bringSubviewToFront:self.extensionViewContainer];
    
    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
}

- (void)cleanup
{
    [self.navBarController expand];
    
    self.previousYOffset = NAN;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self _handleScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self _handleScrollingEnded];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _handleScrollingEnded];
}

#pragma mark - NSNotificationCenter methods

- (void)applicationDidChangeStatusBarFrame
{
    [self prepareForDisplay];
}

- (void)applicationDidBecomeActive
{
    [self.navBarController expand];
}

@end

#pragma mark - UIViewController+TLYShyNavBar category

static char shyNavBarManagerKey;

@implementation UIViewController (ShyNavBar)

#pragma mark - Static methods

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self tly_swizzleInstanceMethod:@selector(viewWillAppear:) withReplacement:@selector(tly_swizzledViewWillAppear:)];
        [self tly_swizzleInstanceMethod:@selector(viewWillLayoutSubviews) withReplacement:@selector(tly_swizzledViewDidLayoutSubviews)];
        [self tly_swizzleInstanceMethod:@selector(viewWillDisappear:) withReplacement:@selector(tly_swizzledViewWillDisappear:)];
    });
}

#pragma mark - Swizzled View Life Cycle

- (void)tly_swizzledViewWillAppear:(BOOL)animated
{
    [[self _internalShyNavBarManager] prepareForDisplay];
    [self tly_swizzledViewWillAppear:animated];
}

- (void)tly_swizzledViewDidLayoutSubviews
{
    [[self _internalShyNavBarManager] layoutViews];
    [self tly_swizzledViewDidLayoutSubviews];
}

- (void)tly_swizzledViewWillDisappear:(BOOL)animated
{
    [[self _internalShyNavBarManager] cleanup];
    [self tly_swizzledViewWillDisappear:animated];
}

#pragma mark - Properties

- (void)setShyNavBarManager:(TLYShyNavBarManager *)shyNavBarManager
{
    shyNavBarManager.viewController = self;
    objc_setAssociatedObject(self, &shyNavBarManagerKey, shyNavBarManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TLYShyNavBarManager *)shyNavBarManager
{
#warning HACK - Disabled for iPad
    id shyNavBarManager = objc_getAssociatedObject(self, &shyNavBarManagerKey);
    if (!shyNavBarManager && ![UIDevice isPad])
    {
        shyNavBarManager = [[TLYShyNavBarManager alloc] init];
        self.shyNavBarManager = shyNavBarManager;
    }
    
    return shyNavBarManager;
}

#pragma mark - Private methods

/* Internally, we need to access the variable without creating it */
- (TLYShyNavBarManager *)_internalShyNavBarManager
{
    return objc_getAssociatedObject(self, &shyNavBarManagerKey);
}

@end


#pragma mark - UINavigationBar Category Implementation

@implementation UINavigationBar (TLYShyNavBar)

// This method is courtesy of GTScrollNavigationBar
// https://github.com/luugiathuy/GTScrollNavigationBar
- (void)updateSubviewsToAlpha:(CGFloat)alpha
{
    for (UIView* view in self.subviews)
    {
        bool isBackgroundView = view == [self.subviews firstObject];
        bool isViewHidden = view.hidden || view.alpha < FLT_EPSILON;
        
        if (!isBackgroundView && !isViewHidden)
        {
            view.alpha = MAX(alpha, FLT_EPSILON);
        }
    }
}

@end
