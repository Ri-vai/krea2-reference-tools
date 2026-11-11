# Krea2 Reference Tools

A dependency-free Go and Swift library for calculating pixel-exact reference
image crops. Use the result to preview framing, compare how much of an image
survives a portrait or landscape crop, or pass the rectangle to an image editor.

Project homepage: [Krea2.io](https://krea2.io/).

## Command line

Go 1.22+:

```sh
go install github.com/Ri-vai/krea2-reference-tools/cmd/krea2-crop@v0.1.0
krea2-crop 1920 1080 4:5 0.8 0.5
```

Swift 5.7+ from the repository:

```sh
swift run krea2-crop 1920 1080 4:5 0.8 0.5
```

Both commands return a rectangle at `x=1056, y=0` with
`width=864, height=1080` and a retained fraction of `0.45`. The requested
focus would center the crop farther to the right, so the rectangle is clamped
at the right edge.

`WIDTH` and `HEIGHT` refer to the orientation in which you intend to crop the
image. The ratio uses positive integer parts, e.g. `4:5`, `16:9` or `47:20`
for 2.35:1. Focus values range from 0 (left or top) to 1 (right or bottom).
The default is (0.5, 0.5). The planner rejects ratios whose reduced dimensions
cannot fit in the source image.

## Library usage

```go
import crop "github.com/Ri-vai/krea2-reference-tools"

// In a function:
result, err := crop.Plan(1920, 1080, crop.Ratio{Width: 4, Height: 5}, 0.8, 0.5)
```

Add the Swift dependency:

```swift
.package(url: "https://github.com/Ri-vai/krea2-reference-tools.git", from: "0.1.0")
```

Then add `.product(name: "ReferenceCrop", package: "krea2-reference-tools")`
to your target dependencies:

```swift
import ReferenceCrop

let crop = try CropPlanner.plan(
    width: 1920, height: 1080, ratio: .init(width: 4, height: 5),
    focusX: 0.8
)
```

The library calculates geometry locally and does not read, upload, or generate
images. Apply the returned rectangle with your image processing library.

## License

MIT. See [LICENSE](LICENSE).
