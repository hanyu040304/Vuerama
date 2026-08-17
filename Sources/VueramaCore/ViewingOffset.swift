import Foundation

public struct ViewingOffset: Equatable, Sendable {
    public static let maximumPitch = Float.pi * 4 / 9

    public var yaw: Float
    public var pitch: Float

    public init(yaw: Float = 0, pitch: Float = 0) {
        self.yaw = Self.normalizedYaw(yaw)
        self.pitch = min(max(pitch, -Self.maximumPitch), Self.maximumPitch)
    }

    /// Converts a gaze-and-pinch drag into an offset applied to the panorama.
    /// The system head pose remains independent, so both controls compose.
    public mutating func applyDrag(
        horizontal: Float,
        vertical: Float,
        sensitivity: Float = 0.0035
    ) {
        yaw = Self.normalizedYaw(yaw + horizontal * sensitivity)
        pitch = min(
            max(pitch - vertical * sensitivity, -Self.maximumPitch),
            Self.maximumPitch
        )
    }

    public mutating func reset() {
        yaw = 0
        pitch = 0
    }

    private static func normalizedYaw(_ value: Float) -> Float {
        var result = value
        let fullTurn = Float.pi * 2

        while result > Float.pi {
            result -= fullTurn
        }
        while result < -Float.pi {
            result += fullTurn
        }

        return result
    }
}
