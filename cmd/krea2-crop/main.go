package main

import (
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"strings"

	crop "github.com/Ri-vai/krea2-reference-tools"
)

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(args []string) error {
	if len(args) != 3 && len(args) != 5 {
		return fmt.Errorf("usage: krea2-crop WIDTH HEIGHT RATIO [FOCUS_X FOCUS_Y]")
	}

	width, widthErr := strconv.Atoi(args[0])
	height, heightErr := strconv.Atoi(args[1])
	left, right, hasRatio := strings.Cut(args[2], ":")
	ratioWidth, ratioWidthErr := strconv.Atoi(left)
	ratioHeight, ratioHeightErr := strconv.Atoi(right)
	if widthErr != nil || heightErr != nil || !hasRatio || ratioWidthErr != nil || ratioHeightErr != nil {
		return fmt.Errorf("width, height and both ratio parts must be integers")
	}

	focusX, focusY := 0.5, 0.5
	if len(args) == 5 {
		var xErr, yErr error
		focusX, xErr = strconv.ParseFloat(args[3], 64)
		focusY, yErr = strconv.ParseFloat(args[4], 64)
		if xErr != nil || yErr != nil {
			return fmt.Errorf("focus coordinates must be numbers between 0 and 1")
		}
	}

	result, err := crop.Plan(width, height, crop.Ratio{Width: ratioWidth, Height: ratioHeight}, focusX, focusY)
	if err != nil {
		return err
	}
	return json.NewEncoder(os.Stdout).Encode(result)
}
