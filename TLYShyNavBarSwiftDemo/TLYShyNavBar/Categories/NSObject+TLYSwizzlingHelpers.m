//
//  NSObject+TLYSwizzlingHelpers.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/23/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "NSObject+TLYSwizzlingHelpers.h"
#import <objc/runtime.h>

@implementation NSObject (TLYSwizzlingHelpers)

+ (void)tly_swizzleClassMethod:(SEL)originalSelector withReplacement:(SEL)replacementSelector
{
	Method originalMethod = class_getClassMethod([self class], originalSelector);
	Method replacementMethod = class_getClassMethod([self class], replacementSelector);
	method_exchangeImplementations(replacementMethod, originalMethod);
}

+ (void)tly_swizzleInstanceMethod:(SEL)originalSelector withReplacement:(SEL)replacementSelector
{
	Method originalMethod = class_getInstanceMethod([self class], originalSelector);
	Method replacementMethod = class_getInstanceMethod([self class], replacementSelector);
	method_exchangeImplementations(replacementMethod, originalMethod);
}

@end
