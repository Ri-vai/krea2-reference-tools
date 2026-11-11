import 'dart:math' as math;

/// A crop rectangle expressed in source pixels, measured from the top left.
final class PixelCrop {
  const PixelCrop({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.retainedFraction,
  });

  final int x;
  final int y;
  final int width;
  final int height;
  final double retainedFraction;

  Map<String, num> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'retainedFraction': retainedFraction,
  };
}

/// Finds the largest rectangle with the exact requested integer aspect ratio.
///
/// A focus of (0.5, 0.5) centers the crop. Values close to the edges move
/// the rectangle toward the subject while keeping it within the image.
PixelCrop planReferenceCrop({
  required int width,
  required int height,
  required int ratioWidth,
  required int ratioHeight,
  double focusX = 0.5,
  double focusY = 0.5,
}) {
  const maxPixels = 2147483647;
  for (final (name, value) in [
    ('width', width),
    ('height', height),
    ('ratioWidth', ratioWidth),
    ('ratioHeight', ratioHeight),
  ]) {
    RangeError.checkValueInInterval(value, 1, maxPixels, name);
  }
  if (!(focusX >= 0 && focusX <= 1 && focusY >= 0 && focusY <= 1)) {
    throw ArgumentError('Focus coordinates must be between 0 and 1.');
  }

  final divisor = ratioWidth.gcd(ratioHeight);
  final reducedWidth = ratioWidth ~/ divisor;
  final reducedHeight = ratioHeight ~/ divisor;
  final scale = math.min(width ~/ reducedWidth, height ~/ reducedHeight);
  if (scale == 0) {
    throw ArgumentError(
      'Image is too small for a pixel-exact $reducedWidth:$reducedHeight crop.',
    );
  }

  final cropWidth = reducedWidth * scale;
  final cropHeight = reducedHeight * scale;
  return PixelCrop(
    x: _origin(width, cropWidth, focusX),
    y: _origin(height, cropHeight, focusY),
    width: cropWidth,
    height: cropHeight,
    retainedFraction: (cropWidth / width) * (cropHeight / height),
  );
}

int _origin(int imageSize, int cropSize, double focus) {
  final firstPixel = (focus * imageSize - cropSize / 2).round();
  return math.max(0, math.min(firstPixel, imageSize - cropSize));
}
