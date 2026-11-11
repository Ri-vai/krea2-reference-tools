// Package referencecrop calculates exact-ratio crop rectangles for image
// references. The same geometry can be used in a preview and a batch pipeline.
package referencecrop

import (
	"fmt"
	"math"
)

const maxPixels = math.MaxInt32

// Ratio describes the target aspect as two positive integer parts.
type Ratio struct {
	Width, Height int
}

// Crop is a rectangle in source pixel coordinates, measured from the top left.
type Crop struct {
	X                int     `json:"x"`
	Y                int     `json:"y"`
	Width            int     `json:"width"`
	Height           int     `json:"height"`
	RetainedFraction float64 `json:"retainedFraction"`
}

// Plan returns the largest integer crop with the given aspect ratio. The crop
// center follows the normalized focus coordinates, clamped to fit the image.
// A focus of (0.5, 0.5) centers the crop.
func Plan(width, height int, ratio Ratio, focusX, focusY float64) (Crop, error) {
	if !validPixels(width) || !validPixels(height) {
		return Crop{}, fmt.Errorf("source dimensions must be between 1 and %d", maxPixels)
	}
	if !validPixels(ratio.Width) || !validPixels(ratio.Height) {
		return Crop{}, fmt.Errorf("ratio parts must be between 1 and %d", maxPixels)
	}
	if !validFocus(focusX) || !validFocus(focusY) {
		return Crop{}, fmt.Errorf("focus coordinates must be between 0 and 1")
	}
	divisor := gcd(ratio.Width, ratio.Height)
	ratioWidth, ratioHeight := ratio.Width/divisor, ratio.Height/divisor
	scale := min(width/ratioWidth, height/ratioHeight)
	if scale == 0 {
		return Crop{}, fmt.Errorf("image is too small for a pixel-exact %d:%d crop", ratioWidth, ratioHeight)
	}

	cropWidth, cropHeight := ratioWidth*scale, ratioHeight*scale
	return Crop{
		X:                cropOrigin(width, cropWidth, focusX),
		Y:                cropOrigin(height, cropHeight, focusY),
		Width:            cropWidth,
		Height:           cropHeight,
		RetainedFraction: (float64(cropWidth) / float64(width)) * (float64(cropHeight) / float64(height)),
	}, nil
}

func gcd(a, b int) int {
	for b != 0 {
		a, b = b, a%b
	}
	return a
}

func validPixels(value int) bool {
	return value > 0 && value <= maxPixels
}

func validFocus(value float64) bool {
	return value >= 0 && value <= 1
}

func cropOrigin(imageSize, cropSize int, focus float64) int {
	origin := int(math.Round(focus*float64(imageSize) - float64(cropSize)/2))
	return max(0, min(origin, imageSize-cropSize))
}
