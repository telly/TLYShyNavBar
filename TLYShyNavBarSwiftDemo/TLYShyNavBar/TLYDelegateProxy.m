//
//  TLYDelegateProxy.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/27/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import "TLYDelegateProxy.h"
#import <objc/runtime.h>

@interface TLYDelegateProxy ()

@property (nonatomic, weak) id middleMan;

@end

@implementation TLYDelegateProxy

- (instancetype)initWithMiddleMan:(id)middleMan
{
    if (self)
    {
        self.middleMan = middleMan;
    }
    return self;
}

- (NSInvocation *)_copyInvocation:(NSInvocation *)invocation
{
    NSInvocation *copy = [NSInvocation invocationWithMethodSignature:[invocation methodSignature]];
    NSUInteger argCount = [[invocation methodSignature] numberOfArguments];
    
    for (int i = 0; i < argCount; i++)
    {
        char buffer[sizeof(intmax_t)];
        [invocation getArgument:(void *)&buffer atIndex:i];
        [copy setArgument:(void *)&buffer atIndex:i];
    }
    
    return copy;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([self.middleMan respondsToSelector:invocation.selector])
    {
        NSInvocation *invocationCopy = [self _copyInvocation:invocation];
        [invocationCopy invokeWithTarget:self.middleMan];
    }
    
    if ([self.originalDelegate respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:self.originalDelegate];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    id result = [self.originalDelegate methodSignatureForSelector:sel];
    if (!result) {
        result = [self.middleMan methodSignatureForSelector:sel];
    }
    
    return result;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return ([self.originalDelegate respondsToSelector:aSelector]
            || [self.middleMan respondsToSelector:aSelector]);
}

@end
