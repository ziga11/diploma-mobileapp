import 'package:flutter/material.dart';

class DocumentController {
  void doubleTapZoom(bool zoomed, TransformationController tc) {
    if (zoomed) {
      tc.value = Matrix4.identity();
    } else {
      tc.value = Matrix4.identity()..scaleByDouble(1.7, 1.7, 1.7, 1.7);
    }
  }
}
