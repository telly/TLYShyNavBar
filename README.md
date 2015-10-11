
# TLYShyNavBar

![Pod Version](https://cocoapod-badges.herokuapp.com/v/TLYShyNavBar/badge.png)
![Pod License](https://img.shields.io/badge/license-MIT-blue.svg)

This component helps you mimick the navigation bar auto scrolling that you see in the facebook, instagram and other apps. Not only that, but with the ability to add an additional extension that scrolls along as well! It is designed for **ease of use**, and is battle tested in our own [Telly app](https://itunes.apple.com/us/app/telly/id524552885?mt=8)<sup>[1]</sup>!

![Battle Tested!!](resources/battle-tested-demo.gif)

<sub>[1]: AppStore version doesn't have the latest, though. Coming soon. :grin:</sub><br />
<sub>[*]: Content are shown for demo purpose only of how this component is used in the Telly app. We hold the right to show those contents as part of our contract with Sony Pictures.</sub>

## Outline 

+ **[Features](#features)**: See what this component has to offer!
+ **[Quick Start](#quick-start)**: TL;DR people, you'll love this.
+ **[Design Goals](#design-goals)**: The cherished aspects of this component.
+ **[A Deeper Look](#a-deeper-look)**: You're invensted in this now and want to make the most out of it.
+ **[How it Works](#how-it-works)**: The deep stuff...
+ **[Remarks](#remarks)**: Read this before losing all hope.
+ **[Contributors](#contributors)**: Developers that donated their valuable time.
+ **[Author](#author)**: Watashi-da!
+ **[Similar Projects](#similar-projects)**: Similar projects that influenced the project in some way.

## Features

| Feature | Demo |
|---------|---------------------------------------------------------------------------------------------------------
| Optional extension view to the `UINavigationBar`!                               | ![](resources/ShyNavBar-1.gif) |
| Auto expand if below threshold                                                  | ![](resources/ShyNavBar-2.gif) |
| Auto contract if below threshold                                                | ![](resources/ShyNavBar-3.gif) |
| Very responsive, resilient and robust                                           | ![](resources/ShyNavBar-4.gif) |
| Adjustable expansion resistance                                                 | ![](resources/ShyNavBar-5.gif) |
| Plays well with `pushViewController`                                            | ![](resources/ShyNavBar-6.gif) |
| Sticky extension view (Thanks @yukaliao !)                                      | ![](resources/ShyNavBar-7.gif) |
| Sticky navigation bar (Thanks [@TiagoVeloso](https://github.com/TiagoVeloso)!)  | ![](resources/ShyNavBar-9.gif) |
| Fade the entire navbar (Thanks [__@longsview__](https://github.com/longsview)!) | ![](resources/ShyNavBar-8.gif) |

You can test some of these features in the Objective-C demo:

![](resources/features-testing.png)

## Quick Start

1. Get the component
  + Using [CocoaPods](http://cocoapods.org):<br />
    Add the following to you [Podfile](http://guides.cocoapods.org/using/the-podfile.html) `pod 'TLYShyNavBar'`<br />
    Import the header `#import <TLYShyNavBar/TLYShyNavBarManager.h>`


  + Using Submodules:<br />
    Download the project/git submodules, and drag the `TLYShyNavBar` folder to your project. <br />
    Import the header `#import "TLYShyNavBarManager.h"`
 
2. Write one line of code to get started!!

```objc
/* In your UIViewController viewDidLoad or after creating the scroll view. */
self.shyNavBarManager.scrollView = self.scrollView;
```

**IMPORTANT!!** If you are assigning a delegate to your scrollView, do that **before** assigning the scrollView to the `TLYShyNavBarManager`! To learn more, [see below](#how-it-works).

### Using TLYShyNavBar in Swift
If you are building apps in Swift and targeting apps to iOS7 Apples [hidesBarsOnSwipe](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UINavigationController_Class/#//apple_ref/occ/instp/UINavigationController/hidesBarsOnSwipe) will not work because it is in an iOS 8 feature.  As an alternative you can use TLYShyNavBar component in lieu of Apples feature.

To use this component in Swift

1. Clone this git repository locally: `git clone https://github.com/telly/TLYShyNavBar.git`
2. Copy the `TLYShyNavBar` directory into your Swift project. <br />![](resources/Swift-project.png)
3. Create a new header file called `Bridging-Header.h` and add the headers from `TLYShyNavBar` folder.[see headers below](#bridge-headers).
4. Add the bridging header file to the project's build settings.  Search `Bridging Header` in `Build Settings` and add `Bridging-Header.h`. <br />![](resources/Bridged-Header.png)

Now your project is setup to use the TLYShyNavBar component.  Next all you need to do is set the scrollview property in your UIViewController like it was an Objective-c project.

```
/* In your UIViewController viewDidLoad or after creating the scroll view. */
self.shyNavBarManager.scrollView = self.scrollView;
```

#### Bridge Headers
```
#import "TLYShyNavBarManager.h"
#import "TLYShyViewController.h"
#import "TLYDelegateProxy.h"
#import "NSObject+TLYSwizzlingHelpers.h"
#import "UIViewController+BetterLayoutGuides.h"
```


## Design Goals

+ **Ease of Use**: This is the most important, and should never be compromised. Even if compatability breaks or versatility is limited, the component should remain easy to integrate.
+ **Portable**: Less dependencies, lightweight, self-contained, ... etc.
+ **Compatability**: Whenever possible, the component should simply work with whatever you throw at it.

## A Deeper Look

The above example, while small, is complete! It makes the navigation bar enriched with humbility, that it will start getting out of the way when the scroll view starts scrolling. But, you may want to do more than that!

#### ACCESS THE MANAGER OF SHYNESS

Simply access it within your `UIViewController` subclass as a property. The property is lazy loaded for you, so you don't have to instantiate anything:

```objc
self.shyNavBarManager
```

#### ADDING AN EXTENSION VIEW

You can assign your own extension view, and it will appear right beneath the navigation bar. It will slide beneath the navigation bar, before the navigation bar starts shrinking (contracting). Adding an extension view is as simple as:

```objc
/* Also in your UIViewController subclass */
[self.shyNavBarManager setExtensionView:self.toolbar];
```

To stick the extension view to the top and have it remain visible when the navigation bar has been hidden:

```objc
/* Also in your UIViewController subclass */
[self.shyNavBarManager setStickyExtensionView:YES];
```

#### CONTROLLING THE RESISTANCE

When you starting scrolling up (going down the view) or scrolling down (going up the view), you may want the navigation bar to hold off for a certain amount (tolerance) before changing states. (i.e. if the user scrolls down 10 px, don't immediately start showing the contracted navigation bar, but wait till he scrolls, say, 100 px).

You can control that using the following properties on the `shyNavBarManager`:

```objc
/* Control the resistance when scrolling up/down before the navbar 
 * expands/contracts again.
 */
@property (nonatomic) CGFloat expansionResistance;      // default 200
@property (nonatomic) CGFloat contractionResistance;    // default 0
```

## How it Works

OK, I'll admit that I added this section purely to rant about how this project came together, and the decision making process behind it.

#### THE BASICS

At a component-user level, this works by adding a category to `UIViewController` with a `TLYShyNavBarManager` property. The property is lazily loaded, to cut any unnecessary overhead, and lower the barrier of entry. From the property, you can start customizing the `TLYShyNavBarManager` for that view controller.

Now, you may start asking, what about the navigation bar? Well, the navigation bar is accessed from the view controller your using the manager in. Let's break that down...

1. When you access the `shyNavBarManager` for the first time, it is created with the `self` parameter passed to it, effectively binding the `shyNavBarManager` to the `UIViewController`.
2. The `shyNavBarManager` accesses the `UINavigationBar` through the assigned `UIViewController`.

... And that is how the basic setup is done!

#### THE EXTENSION VIEW

When you call `setExtensionView:`, it simply resizes an internal container view, and adds your extension view to it. There is no magic here, just simple, single view extension.

#### CAPTURING SCROLL VIEW EVENTS

This one was a pain... First, the experiments that this project went through included:

+ Observing the contentOffset property
+ Adding self as a `UIGestureRecognizer` target
+ Adding a `UIPanGestureRecognizer` to the scroll view.
+ Make the user implement `UIScrollViewDelegate`, and send us the events.

The above didn't yield the perfect experience we were hoping for, except the last one. It did, however, make for redundant code everywhere, and forced the component user to implement the `UIScrollViewDelegate`. Tha's when the `NSProxy` happened.

When you assign the `scrollView` property to the TLYShyNavBarManager, we attach a proxy object to the `UIScrollView` as the delegate, and then the original delegate to that proxy. The proxy forwards the events we are interested in to the `TLYShyNavBarManager`, and of course, does everything else normally for the original selector, you won't even notice a thing!

#### THE DRAWER CONCEPT

The way the offsets are applied to the navigation bar and extension view is through an elegant doubly linked list implementation. We set the offset to the first node (navigation bar), and ...

+ If it is contracting:
  - We pass the contraction amount to the next node, and it returns a residual amount.

+ If we are expanding:
  - We process the offset in the first node, and pass the residual to the next node. 

It is a simple concept. Say we dragged down by 100 px, and the nav bar was contracted. The navigation bar would take 64 px of that to expand, and then pass the residual 36 px to the next node (extension view) to calculate its offset. The same goes for contracting, but it starts from the last node, all the way up to the navigation bar.

We also add a parent relationship for a single purpose: Make the child follow its parent's offset. So, if the parent (e.g. navigation bar) is scrolling away to the top, we make sure the child accommodates the parent's offset in the calculation, so it appears as if the child is a subview of the parent.

*Note:* Even though there might be an illusion that the views are expanding and contracting, it's really just a translation (scrolling) of the views. There might be an advantage to actually resizing the bounds, so the extension view doesn't appear behind the navigation bar, for example, so that approach might be explored in the future.

## Remarks

There are downsides in making this component as easy to use as it is. If you have read the how it works section carefully, you'd realize that trying to configure the the `shyNavBarManager` before it is included in the `UINavigationController` heirarchy, will break the component, since within the component, we cannot find the navigation bar, and an assert is triggered:

```objc
NSAssert(navbar != nil, @"You are using the component wrong... Please see the README file.");
```

Of course, that can be avoided by creating your own `TLYShyNavBarManager`, like so:

```objc
TLYShyNavBarManager *shyManager = [TLYShyNavBarManager new];
shyManager.expansionResistance = 777.f;

/* ... sometime after the view controller is added to the hierarchy  */
viewController.shyNavBarManager = shyManager;
```

## Contributors

Thanks for everyone who opened an issue, shot me an email, and submitted a PR. Special thanks to those who submitted code that got checked in!

_Sorted vaguely based on contribution according to [this](http://www.commandlinefu.com/commands/view/4519/list-all-authors-of-a-particular-git-project)_

+ Evan D. Schoenberg, M.D 
+ Tony Nuzzi 
+ Xurxo Méndez Pérez 
+ Richard Das 
+ Garret Riddle 
+ Aleksey Kozhevnikov 
+ modastic 
+ Yukan 
+ Remigiusz Herba 
+ Nicholas Long 
+ Koen Buddelmeijer 
+ Anton Sokolchenko 
+ Andrii Novoselskyi 
+ Alek Slater 
+ Aaron Satterfield 

## Author

Mazyod ([@Mazyod](http://twitter.com/mazyod))

## Similar Projects

+ [BLKFlexibleHeightBar](https://github.com/bryankeller/BLKFlexibleHeightBar)
+ [AMScrollingNavbar](https://github.com/andreamazz/AMScrollingNavbar)
+ [GTScrollNavigationBar](https://github.com/luugiathuy/GTScrollNavigationBar)
+ [JKAutoShrinkView](https://github.com/fsjack/JKAutoShrinkView)
+ [SherginScrollableNavigationBar](https://github.com/shergin/SherginScrollableNavigationBar)
