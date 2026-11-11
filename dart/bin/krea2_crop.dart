import 'dart:convert';
import 'dart:io';

import 'package:krea2_reference_crop/krea2_reference_crop.dart';

void main(List<String> args) {
  try {
    if (args.length != 3 && args.length != 5) {
      throw const FormatException(
        'Usage: krea2-crop WIDTH HEIGHT RATIO [FOCUS_X FOCUS_Y]',
      );
    }
    final ratio = args[2].split(':');
    if (ratio.length != 2) {
      throw const FormatException('Ratio must have two integer parts.');
    }
    final crop = planReferenceCrop(
      width: int.parse(args[0]),
      height: int.parse(args[1]),
      ratioWidth: int.parse(ratio[0]),
      ratioHeight: int.parse(ratio[1]),
      focusX: args.length == 5 ? double.parse(args[3]) : 0.5,
      focusY: args.length == 5 ? double.parse(args[4]) : 0.5,
    );
    stdout.writeln(jsonEncode(crop));
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } on ArgumentError catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
