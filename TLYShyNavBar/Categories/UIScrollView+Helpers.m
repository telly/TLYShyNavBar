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
    if (!self.isDragging && !self.isDecelerating && contentInsets.top != self.contentInset.top)
    {
        CGFloat offsetDelta = contentInsets.top - self.contentInset.top;
        
        CGRect bounds = self.bounds;
        bounds.origin.y -= offsetDelta;
        self.bounds = bounds;
    }
    
    self.contentInset = contentInsets;
    self.scrollIndicatorInsets = contentInsets;
}

@end
