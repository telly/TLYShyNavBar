//
//  UIScrollView+Helpers.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 11/13/15.
//  Copyright © 2015 Telly, Inc. All rights reserved.
//

#import "UIScrollView+Helpers.h"

@implementation UIScrollView (Helpers)

// Modify contentInset and scrollIndicatorInsets
- (void)tly_setInsets:(UIEdgeInsets)contentInsets
{
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
}

@end
