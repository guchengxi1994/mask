import 'package:flutter/material.dart';

import 'detailed_setting_model.dart';

class SettingNotifier extends ChangeNotifier {
  bool detailedSettingFormShow = false;
  changeSettingFormVisiblity(bool b) {
    if (detailedSettingFormShow != b) {
      detailedSettingFormShow = b;
      notifyListeners();
    }
  }

  // ignore: avoid_init_to_null
  DetailedSettingModel? model = null;

  setModel(DetailedSettingModel m) {
    model = m;
    notifyListeners();
  }
}
