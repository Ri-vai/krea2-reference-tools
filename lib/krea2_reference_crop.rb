# frozen_string_literal: true

# Calculates reference image crops without decoding or modifying the image.
module Krea2ReferenceCrop
  MAX_PIXELS = 2_147_483_647
  private_constant :MAX_PIXELS

  # A rectangle in source pixels, measured from the top-left corner.
  PixelCrop = Struct.new(
    :x, :y, :width, :height, :retained_fraction, keyword_init: true
  )

  # Finds the largest pixel rectangle with the exact requested aspect ratio.
  #
  # @param width [Integer] image width in pixels
  # @param height [Integer] image height in pixels
  # @param ratio_width [Integer] positive first part of the target aspect ratio
  # @param ratio_height [Integer] positive second part of the target aspect ratio
  # @param focus_x [Numeric] horizontal position from 0 (left) to 1 (right)
  # @param focus_y [Numeric] vertical position from 0 (top) to 1 (bottom)
  # @return [PixelCrop] crop coordinates and fraction of the image retained
  # @raise [ArgumentError] for invalid dimensions, aspect ratios, or focus coordinates
  def self.plan(width:, height:, ratio_width:, ratio_height:, focus_x: 0.5, focus_y: 0.5)
    { width: width, height: height, ratio_width: ratio_width, ratio_height: ratio_height }.each do |name, value|
      unless value.is_a?(Integer) && value.between?(1, MAX_PIXELS)
        raise ArgumentError, "#{name} must be an integer between 1 and #{MAX_PIXELS}"
      end
    end
    unless valid_focus?(focus_x) && valid_focus?(focus_y)
      raise ArgumentError, "focus coordinates must be between 0 and 1"
    end

    divisor = ratio_width.gcd(ratio_height)
    reduced_width = ratio_width / divisor
    reduced_height = ratio_height / divisor
    scale = [width / reduced_width, height / reduced_height].min
    if scale.zero?
      raise ArgumentError, "image is too small for a pixel-exact #{reduced_width}:#{reduced_height} crop"
    end

    crop_width = reduced_width * scale
    crop_height = reduced_height * scale
    PixelCrop.new(
      x: origin(width, crop_width, focus_x),
      y: origin(height, crop_height, focus_y),
      width: crop_width,
      height: crop_height,
      retained_fraction: crop_width.fdiv(width) * crop_height.fdiv(height)
    ).freeze
  end

  def self.valid_focus?(value)
    value.is_a?(Numeric) && value.real? && value.finite? && value.between?(0, 1)
  end
  private_class_method :valid_focus?

  def self.origin(image_size, crop_size, focus)
    (focus * image_size - crop_size.fdiv(2)).round.clamp(0, image_size - crop_size)
  end
  private_class_method :origin
end
