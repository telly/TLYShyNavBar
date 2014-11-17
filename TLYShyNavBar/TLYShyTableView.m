//
//  TLYShyTableView.m
//  TLYShyNavBarDemo
//
//  Created by Bunny Lin on 2014/11/17.
//  Copyright (c) 2014年 Telly, Inc. All rights reserved.
//

#import "TLYShyTableView.h"
@interface TLYShyTableView ()
{
    BOOL _shouldManuallyLayoutHeaderViews;

}

@end


@implementation TLYShyTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark -
#pragma mark Super

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    if(_shouldManuallyLayoutHeaderViews)
        [self layoutHeaderViews];
}

#pragma mark -
#pragma mark Self

- (void) setHeaderViewInsets:(UIEdgeInsets)headerViewInsets
{
    _headerViewInsets = headerViewInsets;
    
    _shouldManuallyLayoutHeaderViews = !UIEdgeInsetsEqualToEdgeInsets(_headerViewInsets, UIEdgeInsetsZero);
    
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark Private

- (void) layoutHeaderViews
{
    const NSUInteger numberOfSections = self.numberOfSections;
    const UIEdgeInsets contentInset = self.contentInset;
    const CGPoint contentOffset = self.contentOffset;
    
    const CGFloat sectionViewMinimumOriginY = contentOffset.y + contentInset.top + _headerViewInsets.top;
    
    //	Layout each header view
    for(NSUInteger section = 0; section < numberOfSections; section++)
    {
        UIView* sectionView = [self headerViewForSection:section];
        
        if(sectionView == nil)
            continue;
        
        const CGRect sectionFrame = [self rectForSection:section];
        
        CGRect sectionViewFrame = sectionView.frame;
        
        sectionViewFrame.origin.y = ((sectionFrame.origin.y < sectionViewMinimumOriginY) ? sectionViewMinimumOriginY : sectionFrame.origin.y);
        
        //	If it's not last section, manually 'stick' it to the below section if needed
        if(section < numberOfSections - 1)
        {
            const CGRect nextSectionFrame = [self rectForSection:section + 1];
            
            if(CGRectGetMaxY(sectionViewFrame) > CGRectGetMinY(nextSectionFrame))
                sectionViewFrame.origin.y = nextSectionFrame.origin.y - sectionViewFrame.size.height;
        }
        
        [sectionView setFrame:sectionViewFrame];
    }
}


@end
