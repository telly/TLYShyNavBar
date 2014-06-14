//
//  TLYShyNavBarManager.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/13/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYShyNavBarController.h"
#import "TLYShyViewController.h"
#import <objc/runtime.h>

// Thanks to SO user, MattDiPasquale
// http://stackoverflow.com/questions/12991935/how-to-programmatically-get-ios-status-bar-height/16598350#16598350

static inline CGFloat AACStatusBarHeight()
{
    CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

static const CGFloat contractionVelocity = 140.f;


@interface TLYShyNavBarManager () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) TLYShyViewController *extensionController;
@property (nonatomic, strong) TLYShyViewController *navBarController;

@property (nonatomic, strong) UIView *extensionViewsContainer;

@property (nonatomic) CGFloat previousYOffset;

@property (nonatomic, getter = isContracting) BOOL isContracting;

@end

@implementation TLYShyNavBarManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.previousYOffset = NAN;
        
        self.navBarController = [[TLYShyViewController alloc] init];
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
        
        self.extensionController = [[TLYShyViewController alloc] init];
        self.extensionController.view = self.extensionViewsContainer;
        self.extensionController.contractionAmount = ^(UIView *view)
        {
            return CGRectGetHeight(view.bounds);
        };
        
        __weak typeof(self) weakSelf = self;
        self.extensionController.expandedCenter = ^(UIView *view)
        {
            return CGPointMake(CGRectGetMidX(view.bounds),
                               CGRectGetMidY(view.bounds) + weakSelf.viewController.topLayoutGuide.length);
        };
    }
    return self;
}

- (void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - Properties

- (void)addExtensionView:(UIView *)view
{
    self.extensionViewsContainer.frame = view.bounds;
    [self.extensionViewsContainer addSubview:view];
}

- (void)setViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    
    [self.extensionViewsContainer removeFromSuperview];
    [self.viewController.view addSubview:self.extensionViewsContainer];
    
    self.navBarController.view = viewController.navigationController.navigationBar;
    
    [self _layoutViews];
}

- (void)setScrollView:(UIScrollView *)scrollView
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    _scrollView = scrollView;
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:NULL];
}

#pragma mark - Private methods

- (void)_layoutViews
{
    [self.extensionController expand];
    
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.top = CGRectGetHeight(self.extensionViewsContainer.bounds) + self.viewController.topLayoutGuide.length;
    
    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
}

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
        
        deltaY = [(self.isContracting ? self.extensionController : self.navBarController) updateYOffset:deltaY];
        [(self.isContracting ? self.navBarController : self.extensionController) updateYOffset:deltaY];
    }
    
    self.previousYOffset = self.scrollView.contentOffset.y;
}

- (void)_handleScrollingEnded
{
    TLYShyViewController *first = (self.isContracting ? self.extensionController : self.navBarController);
    TLYShyViewController *second = (self.isContracting ? self.navBarController : self.extensionController);
    
    CGFloat deltaY = [first snap:self.isContracting];
    deltaY += [second snap:self.isContracting];
    
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

- (void)setShyNavBarController:(TLYShyNavBarManager *)shyNavBarController
{
    shyNavBarController.viewController = self;
    objc_setAssociatedObject(self, &shyNavBarControllerKey, shyNavBarController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TLYShyNavBarManager *)shyNavBarController
{
    return objc_getAssociatedObject(self, &shyNavBarControllerKey);
}

@end

