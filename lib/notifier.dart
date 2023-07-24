import 'package:flutter/material.dart';

import 'model.dart';

class MaskNotifier extends ChangeNotifier {
  final List<MaskModel> models;
  List<MaskModel> filters = [];
  bool filtered = false;

  MaskNotifier({required this.models});

  changeContent(int id, String content) {
    final model = models.where((element) => element.id == id);
    if (model.isEmpty) {
      return;
    }
    model.first.content = content;
    notifyListeners();
  }

  List<MaskModel> get maskModels => !filtered ? models : filters;

  filter(int thres1, int thres2) {
    filters.clear();
    for (final i in models) {
      if (i.satisfied(thres1: thres1, thres2: thres2)) {
        filters.add(i);
      }
    }
    filtered = true;
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
