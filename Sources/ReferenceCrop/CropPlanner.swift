public struct AspectRatio: Equatable, Sendable {
    public let width: Int
    public let height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

/// A rectangle in source pixel coordinates, measured from the top left.
public struct PixelCrop: Codable, Equatable, Sendable {
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int
    public let retainedFraction: Double
}

public enum CropError: Error, CustomStringConvertible {
    case invalidDimensions
    case invalidRatio
    case invalidFocus
    case imageTooSmall(width: Int, height: Int)

    public var description: String {
        switch self {
        case .invalidDimensions:
            return "Source dimensions must be between 1 and 2147483647."
        case .invalidRatio:
            return "Ratio parts must be between 1 and 2147483647."
        case .invalidFocus:
            return "Focus coordinates must be between 0 and 1."
        case let .imageTooSmall(width, height):
            return "Image is too small for a pixel-exact \(width):\(height) crop."
        }
    }
}

public enum CropPlanner {
    private static let validPixelRange = 1...Int(Int32.max)

    /// Calculates the largest exact-ratio crop that fits the image.
    /// Focus coordinates are fractions measured from the top-left corner.
    public static func plan(
        width: Int, height: Int, ratio: AspectRatio,
        focusX: Double = 0.5, focusY: Double = 0.5
    ) throws -> PixelCrop {
        guard validPixelRange.contains(width), validPixelRange.contains(height) else {
            throw CropError.invalidDimensions
        }
        guard validPixelRange.contains(ratio.width), validPixelRange.contains(ratio.height) else {
            throw CropError.invalidRatio
        }
        guard (0.0...1.0).contains(focusX), (0.0...1.0).contains(focusY) else {
            throw CropError.invalidFocus
        }

        let divisor = gcd(ratio.width, ratio.height)
        let ratioWidth = ratio.width / divisor
        let ratioHeight = ratio.height / divisor
        let scale = min(width / ratioWidth, height / ratioHeight)
        guard scale > 0 else {
            throw CropError.imageTooSmall(width: ratioWidth, height: ratioHeight)
        }

        let cropWidth = ratioWidth * scale
        let cropHeight = ratioHeight * scale
        return PixelCrop(
            x: origin(imageSize: width, cropSize: cropWidth, focus: focusX),
            y: origin(imageSize: height, cropSize: cropHeight, focus: focusY),
            width: cropWidth,
            height: cropHeight,
            retainedFraction: (Double(cropWidth) / Double(width)) * (Double(cropHeight) / Double(height))
        )
    }

    private static func gcd(_ a: Int, _ b: Int) -> Int {
        var left = a
        var right = b
        while right != 0 {
            (left, right) = (right, left % right)
        }
        return left
    }

    private static func origin(imageSize: Int, cropSize: Int, focus: Double) -> Int {
        let center = focus * Double(imageSize)
        let firstPixel = Int((center - Double(cropSize) / 2).rounded())
        return max(0, min(firstPixel, imageSize - cropSize))
    }
}
