//
//  TLYViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/12/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYViewController.h"

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
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44.f)];
    view.backgroundColor = [UIColor redColor];
    
    /* Library code */
    self.shyNavBarManager.scrollView = self.scrollView;
    /* Can then be remove by setting the ExtensionView to nil */
    [self.shyNavBarManager setExtensionView:view];
    /* Make the extension view stick to the top */
    [self.shyNavBarManager setStickyExtensionView:YES];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = self.imageView.bounds.size;
}

@end
