//
//  UIViewController+BetterLayoutGuides.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/21/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "UIViewController+BetterLayoutGuides.h"

@implementation UIViewController (BetterLayoutGuides)

- (id<UILayoutSupport>)tly_topLayoutGuide
{
    if (self.parentViewController &&
        ![self.parentViewController isKindOfClass:UINavigationController.class])
    {
        return self.parentViewController.tly_topLayoutGuide;
    }
    else {
        return self.topLayoutGuide;
    }
}

- (id<UILayoutSupport>)tly_bottomLayoutGuide
{
    if (self.parentViewController &&
        ![self.parentViewController isKindOfClass:UINavigationController.class])
    {
        return self.parentViewController.tly_bottomLayoutGuide;
    }
    else {
        return self.bottomLayoutGuide;
    }
}

@end
