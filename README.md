
![TLYShyNavBar banner](http://imgur.com/UVxJLxu.png)<br />
__v1.0, Finally! With better code design, and fully featured!__
-----

![Pod Version](https://img.shields.io/cocoapods/v/TLYShyNavBar.svg)
![Pod License](https://img.shields.io/badge/license-MIT-blue.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

This component helps you mimic the navigation bar auto scrolling that you see in the Facebook, Instagram, 9gag (which uses this!) and other apps. Not only that, but with the ability to add an additional extension that scrolls along as well! It is designed for **ease of use**, and is battle tested in our own [Telly app](https://itunes.apple.com/us/app/telly/id524552885?mt=8)<sup>[1]</sup>!

![Battle Tested!!](resources/battle-tested-demo.gif)

<sub>[1]: AppStore version doesn't have the latest, though. Coming soon. :grin:</sub><br />
<sub>[*]: Content are shown for demo purpose only of how this component is used in the Telly app. We hold the right to show those contents as part of our contract with Sony Pictures.</sub>

## Outline 

+ **[Features](#features)**: See what this component has to offer!
+ **[Quick Start](#quick-start)**: TL;DR people, you'll love this.
+ **[Design Goals](#design-goals)**: The cherished aspects of this component.
+ **[A Deeper Look](#a-deeper-look)**: You're invested in this now and want to make the most out of it.
+ **[How it Works](#how-it-works)**: The deep stuff...
+ **[FAQ](#faq)**: Read this before losing all hope.
+ **[Contributing](#contributing)**: Together, making iOS better.
+ **[Author](#author)**: Watashi-da!
+ **[Similar Projects](#similar-projects)**: Similar projects that influenced the project in some way.

## Features

| Feature | Demo |
|---|---|
| Scroll a `UINavigationBar` with an extension view | ![](resources/basic-feature.gif) |
| Support opaque and translucent `UINavigationBar`s | ![](resources/opaque-supported.gif) |
| Fully featured, with animations and variable resistance | ![](resources/fully-featured.gif) |
| Responsive, resilient and robust | ![](resources/robust.gif) |
| Supports `UITableView`, with headers, too! | ![](resources/tableview.gif) |
| `UICollectionView` is more than welcome | ![](resources/collectionView.gif) |
| In-call status bar? No problem! | ![](resources/in-app-call.gif) |
| Sticky extension view (Thanks @yukaliao !) | ![](resources/sticky-extension.gif) |
| Sticky navigation bar (Thanks [@TiagoVeloso](https://github.com/beloso)!)  | ![](resources/sticky-navbar.gif) |
| Fade the entire navbar (Thanks [__@longsview__](https://github.com/longsview)!) | ![](resources/fade-navbar.gif) |

You can test some of these features in the Objective-C demo:

![](resources/features-testing.png)

## Quick Start

1. Get the component
  + Using [CocoaPods](http://cocoapods.org):<br />
    Add the following to you [Podfile](http://guides.cocoapods.org/using/the-podfile.html) `pod 'TLYShyNavBar'`<br />
    Import the header `#import <TLYShyNavBar/TLYShyNavBarManager.h>`

  + Using [Carthage](https://github.com/Carthage/Carthage) (Thanks [@bradleyayers](https://github.com/bradleyayers)!):<br />
    Add the following to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md) `github "telly/TLYShyNavBar"`<br />
    Import the header `#import <TLYShyNavBar/TLYShyNavBar.h>`

  + Using Submodules:<br />
    Download the project/git submodules, and drag the `TLYShyNavBar` folder to your project. <br />
    Import the header `#import "TLYShyNavBarManager.h"`
 
2. Write one line of code to get started!!

```objc
/* In your UIViewController viewDidLoad or after creating the scroll view. */
self.shyNavBarManager.scrollView = self.scrollView;
```

**IMPORTANT NOTES!!** 

1. Don't use with `UITableViewController`. Add a `UITableView` as a subview of `UIViewController` instead.
2. If you are assigning a delegate to your scrollView, do that **before** assigning the scrollView to the `TLYShyNavBarManager`! To learn more, [see below](#how-it-works).

### Using TLYShyNavBar in Swift

Nothing special is needed, really. Just make sure you have a [Bridging Header](http://stackoverflow.com/questions/31716413/xcode-not-automatically-creating-bridging-header) setup, and import:

```objc
#import "TLYShyNavBarManager.h"
```

Then, you should be able to follow the Objective-C instructions, since the code is almost identical.

## Design Goals

+ **Ease of Use**: This is the most important, and should never be compromised. Even if compatability breaks or versatility is limited, the component should remain easy to integrate.
+ **Portable**: Less dependencies, lightweight, self-contained, ... etc.
+ **Compatability**: Whenever possible, the component should simply work with whatever you throw at it.

## A Deeper Look

The above example, while small, is complete! It makes the navigation bar enriched with humility, that it will start getting out of the way when the scroll view starts scrolling. But, you may want to do more than that!

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

#### CONTROLLING THE FADE BEHAVIOR

You can customize the fade behavior of the `UINavigationBar` through this property:

```objc
/* Choose how the navbar fades as it contracts/expands.
 * Defaults to FadeSubviews
 */
@property (nonatomic) TLYShyNavBarFade fadeBehavior;
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

The above didn't yield the perfect experience we were hoping for, except the last one. It did, however, make for redundant code everywhere, and forced the component user to implement the `UIScrollViewDelegate`. That's when the `NSProxy` happened.

When you assign the `scrollView` property to the TLYShyNavBarManager, we attach a proxy object to the `UIScrollView` as the delegate, and then the original delegate to that proxy. The proxy forwards the events we are interested in to the `TLYShyNavBarManager`, and of course, does everything else normally for the original selector, you won't even notice a thing!

#### THE DRAWER CONCEPT

The way the offsets are applied to the navigation bar and extension view is through an elegant doubly linked list implementation. We set the offset to the first node (navigation bar), and ...

+ If it is contracting:
  - We pass the contraction amount to the next node, and it returns a residual amount.

+ If we are expanding:
  - We process the offset in the first node, and pass the residual to the next node. 

It is a simple concept. Say we dragged down by 100 px while the navbar was contracted. The navigation bar would take 44 px of that to expand, and then pass the residual 56 px to the next node (extension view) to calculate its offset. The same goes for contracting, but it starts from the last node, all the way up to the navigation bar.

We also add a parent relationship for a single purpose: Make the child follow its parent's offset. So, if the parent (e.g. navigation bar) is scrolling away to the top, we make sure the child accommodates the parent's offset in the calculation, so it appears as if the child is a subview of the parent.

*Note:* Even though there might be an illusion that the views are expanding and contracting, it's really just a translation (scrolling) of the views. There might be an advantage to actually resizing the bounds, so the extension view doesn't appear behind the navigation bar, for example, so that approach might be explored in the future.

## FAQ

#### Opaque Navbar Shows Black Bar When Scrolled Up

You have to check the «Extend Edges» Under Opaque Bars in the View Controller configuration. Credit for this solution goes to @tiois.

#### I get an exception saying: "Please make sure the viewController is already attached to a navigation controller"

There are downsides in making this component as easy to use as it is. If you have read the how it works section carefully, you'd realize that trying to configure the the `shyNavBarManager` before it is included in the `UINavigationController` hierarchy, will break the component, since within the component, we cannot find the navigation bar, and an assert is triggered:

```objc
NSAssert(navbar != nil, @"Please make sure the viewController is already attached to a navigation controller.");
```

Of course, that can be avoided by creating your own `TLYShyNavBarManager`, like so:

```objc
TLYShyNavBarManager *shyManager = [TLYShyNavBarManager new];
shyManager.expansionResistance = 777.f;

/* ... sometime after the view controller is added to the hierarchy  */
viewController.shyNavBarManager = shyManager;
```

## Contributing

PRs are welcome! It is important to test changes, though. Simply go over the demo, make sure nothing is broken. Please do check both translucent and opaque modes. Once all is good, you're good to go!

If it is a feature or bug, it would be greatly appreciated if a new view is added to the demo project demonstrating the bug/feature.

Thanks for everyone who opened an issue, shot me an email, and submitted a PR. Special thanks to those who submitted code that got checked in! This project was made possible with your help. ([See contributors graph](https://github.com/telly/TLYShyNavBar/graphs/contributors))

## Author

Mazyod ([@Mazyod](http://twitter.com/mazyod))

## Similar Projects

+ [BLKFlexibleHeightBar](https://github.com/bryankeller/BLKFlexibleHeightBar)
+ [AMScrollingNavbar](https://github.com/andreamazz/AMScrollingNavbar)
+ [GTScrollNavigationBar](https://github.com/luugiathuy/GTScrollNavigationBar)
+ [JKAutoShrinkView](https://github.com/fsjack/JKAutoShrinkView)
+ [SherginScrollableNavigationBar](https://github.com/shergin/SherginScrollableNavigationBar)
