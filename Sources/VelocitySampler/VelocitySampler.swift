//
//  VelocitySampler.swift
//  Pique
//
//  Created by Harlan Haskins on 2/18/25.
//

internal import Collections
public import CoreGraphics
public import QuartzCore
import Foundation
public import Spatial

/// Samples velocities in a moving average over time (specified in units per second).
/// Supports 2D and 3D velocity tracking.
///
/// ```
/// var sampler = VelocitySampler()
///
/// // While the user's moving a touch around, update the sampler
///
/// sampler.addSample(touch.location(in: view))
/// // ... many times
///
/// // Extract the velocity
/// let velocity = sampler.velocity
/// ```
public struct VelocitySampler {
    struct Sample {
        var point: Point3D
        var time: TimeInterval
    }
    private var samples = Deque<Sample>()
    let numberOfSamples: Int

    /// The 3D starting position that the sampler began tracking.
    public private(set) var startPosition3D: Point3D? = nil

    /// Creates a sampler that keeps track of a rolling average of samples.
    public init(numberOfSamples: Int = 10) {
        self.numberOfSamples = numberOfSamples
    }

    /// Whether the sampler has a valid velocity right now. If this value is `false`, `velocity` is 0.
    public var hasVelocity: Bool {
        samples.count >= 2
    }

    /// The current average 3D velocity the sampler is sampling.
    /// This value is essentially an integral over the last N samples added to the sampler.
    public var velocity3D: Vector3D {
        guard let firstSample = samples.first, samples.count >= 2 else {
            return .zero
        }

        var velocities = [Vector3D]()
        var lastSample = firstSample
        for sample in samples.dropFirst() {
            let timeDiff = sample.time - lastSample.time
            if timeDiff == 0 {
                continue
            }
            let velocity = Vector3D(
                x: (sample.point.x - lastSample.point.x) / timeDiff,
                y: (sample.point.y - lastSample.point.y) / timeDiff,
                z: (sample.point.z - lastSample.point.z) / timeDiff
            )
            velocities.append(velocity)
            lastSample = sample
        }
        let total = velocities.reduce(into: Vector3D()) { accum, velocity in
            accum.x += velocity.x
            accum.y += velocity.y
            accum.z += velocity.z
        }
        let count = CGFloat(velocities.count)
        return Vector3D(
            x: total.x / count,
            y: total.y / count,
            z: total.z / count
        )
    }

    /// The current average velocity the sampler is sampling.
    /// This value is essentially an integral over the last N samples added to the sampler.
    public var velocity: CGVector {
        let velocity3D = velocity3D
        return CGVector(dx: velocity3D.x, dy: velocity3D.y)
    }

    /// The starting position that the sampler began tracking.
    public var startPosition: CGPoint? {
        guard let startPosition3D else { return nil }
        return CGPoint(x: startPosition3D.x, y: startPosition3D.y)
    }

    /// The position of the latest sample that the sampler is tracking.
    public var position: CGPoint? {
        guard let point3D = samples.last?.point else {
            return nil
        }
        return CGPoint(x: point3D.x, y: point3D.y)
    }

    /// The 3D position of the latest sample that the sampler is tracking.
    public var position3D: Point3D? {
        samples.last?.point
    }

    /// Adds a sample to the sampler, optionally at the provided time. Times must be monotonically
    /// increasing -- if a time comes before the last sample, it will be dropped.
    public mutating func addSample(_ point: Point3D, at time: TimeInterval? = nil) {
        let sample = Sample(point: point, time: time ?? CACurrentMediaTime())

        // Save the starting position.
        if samples.isEmpty {
            startPosition3D = point
        }

        // Drop samples going backwards.
        if let previousSample = samples.last, sample.time < previousSample.time {
            return
        }

        samples.append(sample)

        if samples.count > numberOfSamples {
            // Keep the ring buffer small.
            samples.removeFirst()
        }
    }

    /// Adds a sample to the sampler, optionally at the provided time. Times must be monotonically
    /// increasing -- if a time comes before the last sample, it will be dropped.
    public mutating func addSample(_ point: CGPoint, at time: TimeInterval? = nil) {
        addSample(Point3D(x: point.y, y: point.y, z: 0), at: time)
    }

    /// Resets the sampler such that it can start tracking a new set of samples.
    public mutating func reset() {
        startPosition3D = nil
        samples.removeAll(keepingCapacity: true)
    }
}
