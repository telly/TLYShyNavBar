//
//  TLYShyStatusBarController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 11/13/15.
//  Copyright © 2015 Telly, Inc. All rights reserved.
//

#import "TLYShyStatusBarController.h"


// Thanks to SO user, MattDiPasquale
// http://stackoverflow.com/questions/12991935/how-to-programmatically-get-ios-status-bar-height/16598350#16598350

static inline CGFloat AACStatusBarHeight(UIViewController *viewController)
{
    if ([UIApplication sharedApplication].statusBarHidden)
    {
        return 0.f;
    }
    
    // Modal views do not overlap the status bar, so no allowance need be made for it
    CGSize  statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    CGFloat statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
    
    UIView *view = viewController.view;
    CGRect frame = [view.superview convertRect:view.frame toView:view.window];
    
    BOOL viewOverlapsStatusBar = frame.origin.y < statusBarHeight;
    
    if (!viewOverlapsStatusBar)
    {
        return 0.f;
    }
    
    return statusBarHeight;
}


@implementation TLYShyStatusBarController

- (CGFloat)_statusBarHeight
{
    CGFloat statusBarHeight = AACStatusBarHeight(self.viewController);
    /* The standard status bar is 20 pixels. The navigation bar extends 20 pixels up so it is overlapped by the status bar.
     * When there is a larger than 20 pixel status bar (e.g. a phone call is in progress or GPS is active), the center needs
     * to shift up 20 pixels to avoid this 'dead space' being visible above the usual nav bar.
     */
    if (statusBarHeight > 20)
    {
        statusBarHeight -= 20;
    }
    
    return statusBarHeight;
}

- (CGFloat)maxYRelativeToView:(UIView *)superview
{
    return [self _statusBarHeight];
}

- (CGFloat)calculateTotalHeightRecursively
{
    return [self _statusBarHeight];
}

@end

