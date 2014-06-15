//
//  TLYShyNavBarManager.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/13/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyNavBarManager.h"
#import "TLYShyViewController.h"
#import <objc/runtime.h>

// Thanks to SO user, MattDiPasquale
// http://stackoverflow.com/questions/12991935/how-to-programmatically-get-ios-status-bar-height/16598350#16598350

static inline CGFloat AACStatusBarHeight()
{
    CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

@interface TLYShyNavBarManager () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) TLYShyViewController *navBarController;

@property (nonatomic, strong) UIView *extensionViewsContainer;

@property (nonatomic) CGFloat previousYOffset;

@property (nonatomic, getter = isContracting) BOOL isContracting;

@end

@implementation TLYShyNavBarManager

#pragma mark - Init & Dealloc

- (instancetype)init
{
    self = [super init];
    if (self)
    {
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
        
        self.extensionViewsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100.f, 0.f)];
        self.extensionViewsContainer.backgroundColor = [UIColor clearColor];
        
        TLYShyViewController *extensionController = [[TLYShyViewController alloc] init];
        extensionController.view = self.extensionViewsContainer;
        extensionController.contractionAmount = ^(UIView *view)
        {
            return CGRectGetHeight(view.bounds);
        };
        
        __weak typeof(self) weakSelf = self;
        extensionController.expandedCenter = ^(UIView *view)
        {
            return CGPointMake(CGRectGetMidX(view.bounds),
                               CGRectGetMidY(view.bounds) + CGRectGetHeight(weakSelf.navBarController.view.bounds));
        };
        
        self.navBarController.child = extensionController;
    }
    return self;
}

- (void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - Properties

- (void)setViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    
    UIView *navbar = viewController.navigationController.navigationBar;
    
    [self.extensionViewsContainer removeFromSuperview];
    [navbar insertSubview:self.extensionViewsContainer atIndex:0];
    
    self.navBarController.view = navbar;
    
    [self layoutViews];
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    _scrollView = scrollView;
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:NULL];
}

#pragma mark - Private methods

- (void)_handleScrolling
{
    if (!isnan(self.previousYOffset))
    {
        CGFloat deltaY = (self.previousYOffset - self.scrollView.contentOffset.y);

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
        
        if (fabs(deltaY) > FLT_EPSILON)
        {
            self.isContracting = deltaY < 0;
        }
        
        [self.navBarController updateYOffset:deltaY];
    }
    
    self.previousYOffset = self.scrollView.contentOffset.y;
}

- (void)_handleScrollingEnded
{
    NSTimeInterval duration = 0;
    CGFloat deltaY = 0;
    
    deltaY = [self.navBarController snap:self.isContracting afterDelay:duration];
    duration = fabs(deltaY/contractionVelocity);
    
    CGPoint newContentOffset = self.scrollView.contentOffset;
    newContentOffset.y -= deltaY;
    
    [UIView animateWithDuration:fabs(deltaY/contractionVelocity)
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.scrollView.contentOffset = newContentOffset;
                     } completion:nil];
}

#pragma mark - public methods

- (void)layoutViews
{
    [self.navBarController expand];
    
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.top = CGRectGetHeight(self.extensionViewsContainer.bounds) + self.viewController.topLayoutGuide.length;
    
    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
}

- (void)addExtensionView:(UIView *)view
{
    // TODO: expand the container instead of just adding it on top
    self.extensionViewsContainer.frame = view.bounds;
    [self.extensionViewsContainer addSubview:view];
}

- (void)scrollViewDidEndScrolling
{
    [self _handleScrollingEnded];
}

#pragma mark - KVO methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:NSStringFromSelector(@selector(contentOffset))])
    {
        [self _handleScrolling];
    }
}

@end


static char shyNavBarManagerKey;

@implementation UIViewController (ShyNavBar)

- (void)setShyNavBarManager:(TLYShyNavBarManager *)shyNavBarManager
{
    shyNavBarManager.viewController = self;
    objc_setAssociatedObject(self, &shyNavBarManagerKey, shyNavBarManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TLYShyNavBarManager *)shyNavBarManager
{
    return objc_getAssociatedObject(self, &shyNavBarManagerKey);
}

@end

