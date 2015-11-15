//
//  TLYShyParent.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 11/13/15.
//  Copyright © 2015 Telly, Inc. All rights reserved.
//

#ifndef TLYShyParent_h
#define TLYShyParent_h

#import <UIKit/UIKit.h>

/** A shy parent can be asked for its maxY and height so the 
 *  child can pin itself to the bottom and calculate the total
 *  height.
 */
@protocol TLYShyParent <NSObject>

- (CGFloat)maxYRelativeToView:(UIView *)superview;
- (CGFloat)calculateTotalHeightRecursively;

@end

#endif /* TLYShyParent_h */
