import Testing
@testable import VelocitySampler
import CoreGraphics
import Spatial

@Suite
struct VelocitySamplerTests {
    @Test func testEmpty() async throws {
        let sampler = VelocitySampler()
        #expect(!sampler.hasVelocity)
        #expect(sampler.velocity == .zero)
        #expect(sampler.velocity3D == .zero)
    }

    @Test func testOnlyOneSample() async throws {
        var sampler = VelocitySampler()
        sampler.addSample(Point3D())
        #expect(!sampler.hasVelocity)
        #expect(sampler.velocity == .zero)
        #expect(sampler.velocity3D == .zero)
    }

    @Test func testValidSamples() async throws {
        var sampler = VelocitySampler()
        sampler.addSample(Point3D(), at: 0)

        // move 1 unit in 1 second
        sampler.addSample(Point3D(x: 1, y: 1, z: 1), at: 1)

        #expect(sampler.hasVelocity)
        #expect(sampler.velocity == CGVector(dx: 1, dy: 1))
        #expect(sampler.velocity3D == Vector3D(x: 1, y: 1, z: 1))

        // move another 1 unit in 3 seconds
        sampler.addSample(Point3D(x: 2, y: 2, z: 2), at: 5)
        
        #expect(sampler.velocity3D == Vector3D(x: 0.625, y: 0.625, z: 0.625))
    }
}
