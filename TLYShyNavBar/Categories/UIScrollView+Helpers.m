//
//  UIScrollView+Helpers.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 11/13/15.
//  Copyright © 2015 Telly, Inc. All rights reserved.
//

#import "UIScrollView+Helpers.h"

@implementation UIScrollView (Helpers)

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
