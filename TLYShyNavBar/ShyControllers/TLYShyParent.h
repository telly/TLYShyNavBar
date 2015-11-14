//
//  TLYShyParent.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 11/13/15.
//  Copyright © 2015 Telly, Inc. All rights reserved.
//

#ifndef TLYShyParent_h
#define TLYShyParent_h

@protocol TLYShyParent <NSObject>

@property (nonatomic, readonly) CGFloat viewMaxY;

- (CGFloat)calculateTotalHeightRecursively;

@end

#endif /* TLYShyParent_h */
