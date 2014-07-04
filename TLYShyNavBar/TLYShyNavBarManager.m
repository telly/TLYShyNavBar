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
    CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

#pragma mark - UINavigationController Category interface

/*  CATEGORY DESCRIPTION:
 *  =====================
 *      We set the navigation bar to hidden in TLYShyNavBarManager,
 *  but then we need to restore it in the next view controller. We
 *  use this category to add a flag if it was us whom hid the navbar.
 */

@interface UINavigationController (TLYShyNavBar)

@property (nonatomic) BOOL didShyNavBarManagerHideNavBar;

@end

#pragma mark - TLYShyNavBarManager class

@interface TLYShyNavBarManager () <UIScrollViewDelegate>

@property (nonatomic, strong) TLYShyViewController *navBarController;
@property (nonatomic, strong) TLYShyViewController *extensionController;

@property (nonatomic, strong) TLYDelegateProxy *delegateProxy;

@property (nonatomic, strong) UIView *extensionViewContainer;
@property (nonatomic, weak) UIView *statusBarBackgroundView;

@property (nonatomic) UIEdgeInsets previousScrollInsets;
@property (nonatomic) CGFloat previousYOffset;
@property (nonatomic) CGFloat resistanceConsumed;

@property (nonatomic, getter = isContracting) BOOL contracting;
@property (nonatomic, getter = isViewControllerVisible) BOOL viewControllerVisible;
@property (nonatomic) BOOL previousContractionState;

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
        self.previousContractionState = NO;
        
        self.expansionResistance = 200.f;
        self.contractionResistance = 0.f;
        
        [self _resetCacheVariables];
        
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
    }}

- (CGRect)extensionViewBounds
{
    return self.extensionViewContainer.bounds;
}

#pragma mark - Private methods

- (void)_resetCacheVariables
{
    self.previousYOffset = NAN;
    self.previousScrollInsets = UIEdgeInsetsZero;
    self.resistanceConsumed = 0;
}

- (void)_viewWillAppear
{
    [self _resetCacheVariables];
    self.viewControllerVisible = YES;
}

- (void)_viewWillDisappear
{
    if (self.isContracting)
    {
        UINavigationController *navController = self.viewController.navigationController;
        [navController setNavigationBarHidden:YES animated:YES];
        navController.didShyNavBarManagerHideNavBar = YES;
        
        UIView *snapshotView = [self.viewController.view.window snapshotViewAfterScreenUpdates:NO];
        
        CGRect clippingFrame = snapshotView.frame;
        clippingFrame.size.height = AACStatusBarHeight();
        
        UIView *clippingView = [[UIView alloc] initWithFrame:clippingFrame];
        clippingView.backgroundColor = [UIColor clearColor];
        clippingView.clipsToBounds = YES;
        
        [clippingView addSubview:snapshotView];
        [self.viewController.view addSubview:clippingView];
        
        self.statusBarBackgroundView = clippingView;
    }
    
    self.viewControllerVisible = NO;
}

- (void)_viewDidDisappear
{
    [self.statusBarBackgroundView removeFromSuperview];
}

- (void)_handleScrolling
{
    if (!self.isViewControllerVisible)
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
        CGFloat maxContentOffset = self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds);
        CGFloat end = floorf(maxContentOffset + self.scrollView.contentInset.bottom - 0.5f);
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
    self.contracting = self.navBarController.isContracted;
    
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
    NSAssert([self.extensionViewContainer.subviews count] <= 1,
             @"Please don't tamper with this view! Thanks!");
    
    UIView *previousExtensionView = [self.extensionViewContainer.subviews firstObject];
    if (view != previousExtensionView)
    {
        [previousExtensionView removeFromSuperview];
        
        CGRect bounds = view.frame;
        bounds.origin = CGPointZero;
        
        view.frame = bounds;
        
        self.extensionViewContainer.frame = bounds;
        [self.extensionViewContainer addSubview:view];
        
        [self layoutViews];
    }
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
        [self tly_swizzleInstanceMethod:@selector(viewDidDisappear:) withReplacement:@selector(tly_swizzledViewDidDisappear:)];
    });
}

#pragma mark - Swizzled View Life Cycle

- (void)tly_swizzledViewWillAppear:(BOOL)animated
{
    [[self _internalShyNavBarManager] _viewWillAppear];
    
    if (self.navigationController.viewControllers.count > 1)
    {
        NSUInteger index = self.navigationController.viewControllers.count - 2;
        UIViewController *previousController = self.navigationController.viewControllers[index];
        
        if (self.navigationController.didShyNavBarManagerHideNavBar)
        {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    }
    
    [self tly_swizzledViewWillAppear:animated];
}

- (void)tly_swizzledViewDidLayoutSubviews
{
    [[self _internalShyNavBarManager] layoutViews];
    [self tly_swizzledViewDidLayoutSubviews];
}

- (void)tly_swizzledViewWillDisappear:(BOOL)animated
{
    [[self _internalShyNavBarManager] _viewWillDisappear];
    [self tly_swizzledViewWillDisappear:animated];
}

- (void)tly_swizzledViewDidDisappear:(BOOL)animated
{
    [[self _internalShyNavBarManager] _viewDidDisappear];
    [self tly_swizzledViewDidDisappear:animated];
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

#pragma mark - UINavigationController Category implementation

const void *didShyNavBarManagerHideNavBarKey = &didShyNavBarManagerHideNavBarKey;

@implementation UINavigationController (TLYShyNavBar)

- (void)setDidShyNavBarManagerHideNavBar:(BOOL)didShyNavBarManagerHideNavBar
{
    objc_setAssociatedObject(self, didShyNavBarManagerHideNavBarKey, @(didShyNavBarManagerHideNavBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)didShyNavBarManagerHideNavBar
{
    return [objc_getAssociatedObject(self, didShyNavBarManagerHideNavBarKey) boolValue];
}

@end

