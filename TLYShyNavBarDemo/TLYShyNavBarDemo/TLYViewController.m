//
//  TLYViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/12/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYViewController.h"

@interface TLYViewController ()

@property (nonatomic, assign) IBInspectable BOOL disableExtensionView;
@property (nonatomic, assign) IBInspectable BOOL stickyNavigationBar;
@property (nonatomic, assign) IBInspectable BOOL stickyExtensionView;
@property (nonatomic, assign) IBInspectable NSInteger fadeBehavior;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation TLYViewController

#pragma mark - Init & Dealloc

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.disableExtensionView = NO;
        self.stickyNavigationBar = NO;
        self.stickyExtensionView = NO;
        self.fadeBehavior = TLYShyNavBarFadeSubviews;
        
        self.title = @"WTFox Say";
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *view = nil;
    
    if (!self.disableExtensionView)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40.f)];
        view.backgroundColor = [UIColor redColor];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = view.bounds;
        [button addTarget:self action:@selector(extensionViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Click Me!" forState:UIControlStateNormal];
        
        [view addSubview:button];
    }
    
    /* Library code */
    self.shyNavBarManager.scrollView = self.scrollView;
    /* Can then be remove by setting the ExtensionView to nil */
    [self.shyNavBarManager setExtensionView:view];
    /* Make navbar stick to the top */
    [self.shyNavBarManager setStickyNavigationBar:self.stickyNavigationBar];
    /* Make the extension view stick to the top */
    [self.shyNavBarManager setStickyExtensionView:self.stickyExtensionView];
    /* Navigation bar fade behavior */
    [self.shyNavBarManager setFadeBehavior:self.fadeBehavior];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = self.imageView.bounds.size;
}

#pragma mark - Action methods

- (void)extensionViewTapped:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"it works" message:nil delegate:nil cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
}

@end
