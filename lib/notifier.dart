import 'package:flutter/material.dart';

import 'model.dart';

class MaskNotifier extends ChangeNotifier {
  final List<MaskModel> models;

  MaskNotifier({required this.models});

  changeContent(int id, String content) {
    final model = models.where((element) => element.id == id);
    if (model.isEmpty) {
      return;
    }
    model.first.content = content;
    notifyListeners();
  }

  bool getVisible(int id) {
    final model = models.where((element) => element.id == id);
    if (model.isEmpty) {
      return true;
    }
    return model.first.visible;
  }

  changeVisible(int id, bool b) {
    final model = models.where((element) => element.id == id);
    if (model.isEmpty) {
      return;
    }
    model.first.visible = b;
    notifyListeners();
  }

  removeById(int id) {
    models.retainWhere((element) => element.id != id);
    notifyListeners();
  }
}
