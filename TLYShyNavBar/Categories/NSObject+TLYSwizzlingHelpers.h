//
//  NSObject+TLYSwizzlingHelpers.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/23/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TLYSwizzlingHelpers)

+ (void)tly_swizzleClassMethod:(SEL)originalSelector withReplacement:(SEL)replacementSelector;
+ (void)tly_swizzleInstanceMethod:(SEL)originalSelector withReplacement:(SEL)replacementSelector;

@end
