# VelocitySampler

A small Swift struct for computing a rolling average of 2D or 3D velocities (usually driven by a touch).

## Installation

VelocitySampler can be added to your project using Swift Package Manager. For more
information on using SwiftPM in Xcode, see [Apple's guide](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

If you're using package dependencies directly, you can add this as one of your dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/harlanhaskins/VelocitySampler.git", from: "0.0.1")
]
```

## Usage

`VelocitySampler` is a struct that you progressively add more and more samples to. It maintains
an internal ring buffer of N samples that it keeps track of and continually averages.

```swift
var sampler = VelocitySampler()

// While the user's moving a touch around, update the sampler

sampler.addSample(touch.location(in: view))
// ... repeat many times

// Extract the velocity
let velocity = sampler.velocity
print(velocity) // Do something with it
```

## Author

Harlan Haskins ([harlan@harlanhaskins.com](mailto:harlan@harlanhaskins.com))
