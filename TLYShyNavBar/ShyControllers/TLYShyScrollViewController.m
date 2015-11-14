//
//  TLYShyScrollViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 11/13/15.
//  Copyright © 2015 Telly, Inc. All rights reserved.
//

#import "TLYShyScrollViewController.h"
#import "../Categories/UIScrollView+Helpers.h"


@interface TLYShyScrollViewController ()

@property (nonatomic, assign) UIEdgeInsets previousScrollInsets;

@end

@implementation TLYShyScrollViewController

- (void)offsetCenterBy:(CGPoint)deltaPoint
{
    [self updateLayoutIfNeeded:NO];
}

- (BOOL)updateLayoutIfNeeded:(BOOL)intelligently
{
    CGFloat parentMaxY = [self.parent maxYRelativeToView:self.scrollView.superview];
    CGFloat normalizedY = parentMaxY - self.scrollView.frame.origin.y;
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.top = normalizedY;
    
    if (normalizedY > 0 && !UIEdgeInsetsEqualToEdgeInsets(insets, self.previousScrollInsets))
    {
        if (intelligently)
        {
            [self.scrollView tly_smartSetInsets:insets];
            self.previousScrollInsets = insets;
        }
        else
        {
            self.scrollView.contentInset = insets;
            self.scrollView.scrollIndicatorInsets = insets;
        }
        
        return true;
    }
    
    if (normalizedY < 0)
    {        
        CGRect frame = self.scrollView.frame;
        frame = UIEdgeInsetsInsetRect(frame, insets);
        
        self.scrollView.frame = frame;
        return true;
    }
    
    return false;
}

@end
