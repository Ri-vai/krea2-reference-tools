import 'dart:convert';

import 'package:krea2_reference_crop/krea2_reference_crop.dart';

void main() {
  final crop = planReferenceCrop(
    width: 1920,
    height: 1080,
    ratioWidth: 4,
    ratioHeight: 5,
    focusX: 0.8,
  );
  print(jsonEncode(crop));
}
