# Krea2 Reference Crop

Calculate an exact-ratio crop before fitting a reference image into a portrait
or landscape frame. The planner returns source-pixel coordinates and the
fraction of the image retained by the crop.

## Install and use

```sh
dart pub add krea2_reference_crop
```

```dart
import 'package:krea2_reference_crop/krea2_reference_crop.dart';

final crop = planReferenceCrop(
  width: 1920,
  height: 1080,
  ratioWidth: 4,
  ratioHeight: 5,
  focusX: 0.8,
);
```

The crop is 864 × 1080 at (1056, 0) and retains 45% of the source area.
The planner clamps the rectangle at the right edge so it stays within the
image. Focus coordinates are measured from the top left on a scale from 0 to 1.

## Command line

```sh
dart pub global activate krea2_reference_crop
dart pub global run krea2_reference_crop:krea2_crop 1920 1080 4:5 0.8 0.5
```

Use the result with your preferred image processing library. The package
computes geometry locally and accepts dimensions in the orientation you intend
to crop. It requires no image upload, account, or network request at runtime.

Project homepage: [Krea2.io](https://krea2.io/).
