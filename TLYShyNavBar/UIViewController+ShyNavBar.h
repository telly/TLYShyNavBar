//
//  UIViewController+ShyNavBar.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/12/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ShyNavBar)

- (void)tly_scrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)tly_scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)tly_scrollViewDidEndDragging:(UIScrollView *)scrollView;

@end
