//
//  TLYDelegateProxy.h
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 6/27/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*  CLASS DESCRIPTION:
 *  ==================
 *      Delegate proxy is meant to be used as a proxy between and 
 *  object and its delegate. The DelegateProxy is initialized with a
 *  target and middle man, where the target is the original delegate
 *  and the middle-man is just an object we send identical messages to.
 */

@interface TLYDelegateProxy : NSProxy

@property (nonatomic, weak) id originalDelegate;

- (instancetype)initWithMiddleMan:(id)middleMan;

@end
