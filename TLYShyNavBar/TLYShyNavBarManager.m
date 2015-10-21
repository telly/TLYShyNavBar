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

static inline CGFloat AACStatusBarHeight(UIViewController *viewController)
{
    if ([UIApplication sharedApplication].statusBarHidden)
    {
        return 0.f;
    }
    
    // Modal views do not overlap the status bar, so no allowance need be made for it
    CGSize  statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    CGFloat statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
    
    UIView *view = viewController.view;
    CGRect frame = [view.superview convertRect:view.frame toView:view.window];
    
    BOOL viewOverlapsStatusBar = frame.origin.y < statusBarHeight;
    
    if (!viewOverlapsStatusBar)
    {
        return 0.f;
    }
    
    return statusBarHeight;
}

static void * const kTLYShyNavBarManagerKVOContext = (void*)&kTLYShyNavBarManagerKVOContext;

@implementation UIScrollView(Helper)

// Modify contentInset and scrollIndicatorInsets while preserving visual content offset
- (void)tly_smartSetInsets:(UIEdgeInsets)contentAndScrollIndicatorInsets
{
    if (contentAndScrollIndicatorInsets.top != self.contentInset.top)
    {
        CGPoint contentOffset = self.contentOffset;
        contentOffset.y -= contentAndScrollIndicatorInsets.top - self.contentInset.top;
        self.contentOffset = contentOffset;
    }

    self.contentInset = self.scrollIndicatorInsets = contentAndScrollIndicatorInsets;
}

@end


@interface TLYShyStatusBarController : NSObject <TLYShyViewControllerParent>

@property (nonatomic, weak) UIViewController *viewController;

@end

@implementation TLYShyStatusBarController

- (CGFloat)_statusBarHeight
{
    CGFloat statusBarHeight = AACStatusBarHeight(self.viewController);
    /* The standard status bar is 20 pixels. The navigation bar extends 20 pixels up so it is overlapped by the status bar.
     * When there is a larger than 20 pixel status bar (e.g. a phone call is in progress or GPS is active), the center needs
     * to shift up 20 pixels to avoid this 'dead space' being visible above the usual nav bar.
     */
    if (statusBarHeight > 20)
    {
        statusBarHeight -= 20;
    }
    
    return statusBarHeight;
}

- (CGFloat)viewMaxY
{
    return [self _statusBarHeight];
}

- (CGFloat)calculateTotalHeightRecursively
{
    return [self _statusBarHeight];
}

@end


#pragma mark - TLYShyNavBarManager class

@interface TLYShyNavBarManager () <UIScrollViewDelegate>

@property (nonatomic, strong) id<TLYShyViewControllerParent> statusBarController;
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
        
        self.fadeBehavior = TLYShyNavBarFadeSubviews;
        
        self.previousScrollInsets = UIEdgeInsetsZero;
        self.previousYOffset = NAN;
        
        self.statusBarController = [[TLYShyStatusBarController alloc] init];
        
        self.navBarController = [[TLYShyViewController alloc] init];
        self.navBarController.parent = self.statusBarController;
        
        self.extensionViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100.f, 0.f)];
        self.extensionViewContainer.backgroundColor = [UIColor clearColor];
        self.extensionViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        
        self.extensionController = [[TLYShyViewController alloc] init];
        self.extensionController.view = self.extensionViewContainer;
        self.extensionController.parent = self.navBarController;

        self.navBarController.child = self.extensionController;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidChangeStatusBarFrame:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
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
    [_scrollView removeObserver:self forKeyPath:@"contentSize" context:kTLYShyNavBarManagerKVOContext];
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
    [_scrollView removeObserver:self forKeyPath:@"contentSize" context:kTLYShyNavBarManagerKVOContext];
    
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
    
    [_scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:kTLYShyNavBarManagerKVOContext];
}

- (CGRect)extensionViewBounds
{
    return self.extensionViewContainer.bounds;
}

- (BOOL)isViewControllerVisible
{
    return self.viewController.isViewLoaded && self.viewController.view.window;
}

- (void)setDisable:(BOOL)disable
{
    if (disable == _disable)
    {
        return;
    }

    _disable = disable;

    if (!disable) {
        self.previousYOffset = self.scrollView.contentOffset.y;
    }
}

- (BOOL)stickyNavigationBar
{
    return self.navBarController.sticky;
}

- (void)setStickyNavigationBar:(BOOL)stickyNavigationBar
{
    self.navBarController.sticky = stickyNavigationBar;
}

- (BOOL)stickyExtensionView
{
    return self.extensionController.sticky;
}

- (void)setStickyExtensionView:(BOOL)stickyExtensionView
{
    self.extensionController.sticky = stickyExtensionView;
}


#pragma mark - Private methods

- (BOOL)_scrollViewIsSuffecientlyLong
{
    CGRect scrollFrame = UIEdgeInsetsInsetRect(self.scrollView.bounds, self.scrollView.contentInset);
    CGFloat scrollableAmount = self.scrollView.contentSize.height - CGRectGetHeight(scrollFrame);
    return (scrollableAmount > self.navBarController.totalHeight);
}

- (BOOL)_shouldHandleScrolling
{
    if (self.disable)
    {
        return NO;
    }
    return (self.isViewControllerVisible && [self _scrollViewIsSuffecientlyLong]);
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
            deltaY = MIN(0, deltaY - (self.previousYOffset - start));
        }
        
        /* rounding to resolve a dumb issue with the contentOffset value */
        CGFloat end = floorf(self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds) + self.scrollView.contentInset.bottom - 0.5f);
        if (self.previousYOffset > end && deltaY > 0)
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
        else if (self.scrollView.contentOffset.y > -AACStatusBarHeight(self.viewController))
        {
            CGFloat availableResistance = self.expansionResistance - self.resistanceConsumed;
            self.resistanceConsumed = MIN(self.expansionResistance, self.resistanceConsumed + deltaY);
            
            deltaY = MAX(0, deltaY - availableResistance);
        }
        
        // 6 - Update the navigation bar shyViewController
        self.navBarController.fadeBehavior = (TLYShyNavViewControllerFade)self.fadeBehavior;
        
        
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

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == kTLYShyNavBarManagerKVOContext)
    {
        if (self.isViewControllerVisible && ![self _scrollViewIsSuffecientlyLong])
        {
            [self.navBarController expand];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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
        self.extensionViewContainer.userInteractionEnabled = view.userInteractionEnabled;

        /* Disable scroll handling temporarily while laying out views to avoid double-changing content
         * offsets in _handleScrolling. */
        BOOL wasDisabled = self.disable;
        self.disable = YES;
        [self layoutViews];
        self.disable = wasDisabled;
    }
}

- (void)prepareForDisplay
{
    [self cleanup];
}

- (void)layoutViews
{
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.top = [self.extensionController calculateTotalHeightRecursively];
    
    if (UIEdgeInsetsEqualToEdgeInsets(scrollInsets, self.previousScrollInsets))
    {
        return;
    }
    
    self.previousScrollInsets = scrollInsets;
    
    [self.navBarController expand];
    [self.extensionViewContainer.superview bringSubviewToFront:self.extensionViewContainer];

    [self.scrollView tly_smartSetInsets:scrollInsets];
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

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.scrollView scrollRectToVisible:CGRectMake(0,0,1,1) animated:YES];
    [self.scrollView flashScrollIndicators];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _handleScrollingEnded];
}

#pragma mark - NSNotificationCenter methods

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self.navBarController expand];
}

- (void)applicationDidChangeStatusBarFrame:(NSNotification *)notification
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


#pragma mark - Deprecated -

@implementation TLYShyNavBarManager (Deprecated)

- (BOOL)isAlphaFadeEnabled
{
    return self.fadeBehavior != TLYShyNavBarFadeDisabled;
}

- (void)setAlphaFadeEnabled:(BOOL)alphaFadeEnabled
{
    self.fadeBehavior = alphaFadeEnabled ? TLYShyNavBarFadeSubviews : TLYShyNavBarFadeDisabled;
}

- (BOOL)isAlphaFadeEntireNavBarEnabled
{
    return self.fadeBehavior != TLYShyNavBarFadeNavbar;
}

- (void)setAlphaFadeEntireNavBar:(BOOL)alphaFadeEntireNavBar
{
    self.fadeBehavior = alphaFadeEntireNavBar ? TLYShyNavBarFadeNavbar : TLYShyNavBarFadeDisabled;
}

@end

