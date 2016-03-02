//
//  TLYShyScrollViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 11/13/15.
//  Copyright © 2015 Telly, Inc. All rights reserved.
//

#import "TLYShyScrollViewController.h"
#import "../Categories/UIScrollView+Helpers.h"


@implementation TLYShyScrollViewController

- (void)offsetCenterBy:(CGPoint)deltaPoint
{
    [self updateLayoutIfNeeded];
}

- (CGFloat)updateLayoutIfNeeded
{
    if (self.scrollView.contentSize.height < FLT_EPSILON
        && ([self.scrollView isKindOfClass:[UITableView class]]
            || [self.scrollView isKindOfClass:[UICollectionView class]])
        )
    {
        return 0.f;
    }

    CGFloat parentMaxY = [self.parent maxYRelativeToView:self.scrollView.superview];
    CGFloat normalizedY = parentMaxY - self.scrollView.frame.origin.y;
    UIEdgeInsets insets = UIEdgeInsetsMake(self.scrollView.contentInset.top, 0, self.scrollView.contentInset.bottom, 0);
    insets.top = normalizedY;

    if (normalizedY > -FLT_EPSILON && !UIEdgeInsetsEqualToEdgeInsets(insets, self.scrollView.contentInset))
    {
        CGFloat delta = insets.top - self.scrollView.contentInset.top;

        if (self.refreshControl == nil || [self.refreshControl isHidden]) {
            [self.scrollView tly_setInsets:insets];
        }

        return delta;
    }

    if (normalizedY < -FLT_EPSILON)
    {
        CGRect frame = self.scrollView.frame;
        frame = UIEdgeInsetsInsetRect(frame, insets);

        self.scrollView.frame = frame;
        return [self updateLayoutIfNeeded];
    }

    return 0.f;
}

@end
