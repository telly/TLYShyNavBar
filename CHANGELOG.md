
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
