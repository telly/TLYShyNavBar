//
//  TLYViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/12/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYViewController.h"

@interface UIBarButtonItem (Telly)

+ (UIBarButtonItem *)tly_flexibleSpaceButtonItem;

@end

@implementation UIBarButtonItem (Telly)

+ (UIBarButtonItem *)tly_flexibleSpaceButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                         target:nil
                                                         action:nil];
}

@end


@interface TLYViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation TLYViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"WTFox Say";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44.f)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    toolbar.barTintColor = [UIColor whiteColor];
    toolbar.opaque = YES;
    toolbar.items = @[[UIBarButtonItem tly_flexibleSpaceButtonItem],
                      [[UIBarButtonItem alloc] initWithTitle:@"One" style:UIBarButtonItemStyleBordered target:nil action:nil],
                      [UIBarButtonItem tly_flexibleSpaceButtonItem],
                      [[UIBarButtonItem alloc] initWithTitle:@"Two" style:UIBarButtonItemStyleBordered target:nil action:nil],
                      [UIBarButtonItem tly_flexibleSpaceButtonItem]];
    
    UIView *view = [[UIView alloc] initWithFrame:toolbar.frame];
    view.backgroundColor = [UIColor redColor];
    
    TLYShyNavBarManager *shyController = [TLYShyNavBarManager new];
    shyController.scrollView = self.scrollView;
    
    /* Can then be remove by setting the ExtensionView to nil */
    [shyController setExtensionView:view];
    
    self.shyNavBarManager = shyController;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.shyNavBarManager layoutViews];
    self.scrollView.contentSize = self.imageView.bounds.size;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self.shyNavBarManager scrollViewDidEndScrolling];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.shyNavBarManager scrollViewDidEndScrolling];
}

@end
