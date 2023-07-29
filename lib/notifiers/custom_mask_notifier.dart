import 'package:flutter/material.dart';

class CustomMaskNotifier extends ChangeNotifier {
  double bndboxPreviewWidth = 0;
  double bndboxPreviewHeight = 0;

  changeBndboxPreviewWidth(double w) {
    if (w > 0) {
      bndboxPreviewWidth = w;
      notifyListeners();
    }
  }

  changeBndboxPreviewHeight(double h) {
    if (h > 0) {
      bndboxPreviewHeight = h;
      notifyListeners();
    }
  }

  bndReset() {
    bndboxPreviewHeight = 0;
    bndboxPreviewWidth = 0;
    notifyListeners();
  }
}
