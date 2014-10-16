//
//  TLYShyNavBarManager.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/13/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyNavBarManager.h"
#import "TLYShyViewController.h"
#import "TLYDelegateProxy.h"

#import "UIViewController+BetterLayoutGuides.h"
#import "NSObject+TLYSwizzlingHelpers.h"

#import <objc/runtime.h>

#pragma mark - Helper functions

// Thanks to SO user, MattDiPasquale
// http://stackoverflow.com/questions/12991935/how-to-programmatically-get-ios-status-bar-height/16598350#16598350

static inline CGFloat AACStatusBarHeight()
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

@property (nonatomic, strong) TLYShyViewController *navBarController;
@property (nonatomic, strong) TLYShyViewController *extensionController;

@property (nonatomic, strong) TLYDelegateProxy *delegateProxy;

@property (nonatomic, strong) UIView *extensionViewContainer;

@property (nonatomic) UIEdgeInsets previousScrollInsets;
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
        
        self.previousScrollInsets = UIEdgeInsetsZero;
        self.previousYOffset = NAN;
        
        self.navBarController = [[TLYShyViewController alloc] init];
        self.navBarController.hidesSubviews = YES;
        self.navBarController.expandedCenter = ^(UIView *view)
        {
            return CGPointMake(CGRectGetMidX(view.bounds),
                               CGRectGetMidY(view.bounds) + AACStatusBarHeight());
        };
        
        self.navBarController.contractionAmount = ^(UIView *view)
        {
            return CGRectGetHeight(view.bounds);
        };
        
        self.extensionViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100.f, 0.f)];
        self.extensionViewContainer.backgroundColor = [UIColor clearColor];
        self.extensionViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        
        self.extensionController = [[TLYShyViewController alloc] init];
        self.extensionController.view = self.extensionViewContainer;
        self.extensionController.hidesAfterContraction = YES;
        self.extensionController.contractionAmount = ^(UIView *view)
        {
            return CGRectGetHeight(view.bounds);
        };
        
        __weak __typeof(self) weakSelf = self;
        self.extensionController.expandedCenter = ^(UIView *view)
        {
            return CGPointMake(CGRectGetMidX(view.bounds),
                               CGRectGetMidY(view.bounds) + weakSelf.viewController.tly_topLayoutGuide.length);
        };
        
        self.navBarController.child = self.extensionController;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
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
    
    UIView *navbar = viewController.navigationController.navigationBar;
    NSAssert(navbar != nil, @"You are using the component wrong... Please see the README file.");
    
    [self.extensionViewContainer removeFromSuperview];
    [self.viewController.view addSubview:self.extensionViewContainer];
    
    self.navBarController.view = navbar;
    
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
        else if (self.scrollView.contentOffset.y > -AACStatusBarHeight())
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
    scrollInsets.top = CGRectGetHeight(self.extensionViewContainer.bounds) + self.viewController.tly_topLayoutGuide.length;
    
    if (UIEdgeInsetsEqualToEdgeInsets(scrollInsets, self.previousScrollInsets))
    {
        return;
    }
    
    self.previousScrollInsets = scrollInsets;
    
    [self.navBarController expand];
    [self.extensionViewContainer.superview bringSubviewToFront:self.extensionViewContainer];

    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
}

- (void)cleanup
{
    [self.navBarController expand];
    
    self.previousYOffset = NAN;
    self.previousScrollInsets = UIEdgeInsetsZero;
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
    id shyNavBarManager = objc_getAssociatedObject(self, &shyNavBarManagerKey);
    if (!shyNavBarManager)
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

