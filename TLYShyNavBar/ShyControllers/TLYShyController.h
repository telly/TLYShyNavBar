//
//  TLYShyController.h
//  Telly
//
//  Created by Mazyad Alabduljaleel on 10/28/14.
//  Copyright (c) 2014 Telly, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const CGFloat contractionVelocity;

/** A shy controller manages a shy object. Shy objects are any
 *  kind of object that will receive scroll deltas and respond
 *  to them in some way.
 *
 *  Currently, there are two ShyControllers:
 *      1- TranslationShyController: uses the delta to perform translations
 *      2- BoundsShyController: uses the delta to update the bounds
 */
@interface TLYShyController : NSObject

@property (nonatomic, weak) TLYShyController *child;
@property (nonatomic, weak) UIView *view;

@property (nonatomic) BOOL hidesSubviews;
@property (nonatomic) BOOL hidesAfterContraction;

@property (nonatomic) BOOL alphaFadeEnabled;

@property (nonatomic, getter = isContracted) BOOL contracted;
@property (nonatomic, getter = isExpanded) BOOL expanded;

@property (nonatomic, readonly) CGFloat phase;
@property (nonatomic, readonly) CGFloat totalHeight;

- (CGFloat)updateYOffset:(CGFloat)deltaY;

/** PROTECTED */
- (CGFloat)performUpdateForDelta:(CGFloat)deltaY;
- (void)updateSubviewsToAlpha:(CGFloat)alpha;
/** PROTECTED */

- (CGFloat)snap:(BOOL)contract;

- (CGFloat)expand;
- (CGFloat)contract;

@end
