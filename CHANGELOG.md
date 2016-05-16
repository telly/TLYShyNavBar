
# Retired

Please see the github releases for release notes

# Legacy

## v0.10.1

#### Fixes

+ Hot fix an issue with UIViewControllers that have a UIScrollView subclass as their view property (i.e. collectionView, tableView, ...) that caused shyNavBar to be stubbornNavBar, refusing to contract.

## v0.10.0

#### Enhancements

+ New approach to calculate extension and navigation bar offsets.<br />
Initially, we externally injected the calculation through blocks. The calculations depended on layout guide, and other weird stuff. The new approach simply calculates the offset based on the parent: status bar -> navigation bar -> extension view.

+ Added support for sticky navigation bar

## v0.9.15

#### Enhancements

+ Added support for fading the entire navigation bar

+ Added modal support by checking navigation bar overlap with status bar

+ Added visual tests in the demo to see all the features in action

#### Fixes

+ Fixed an issue with scrolling to top functionality

#### Deprecations

+ Deprecated the fading booleans in favour of a new enum.
