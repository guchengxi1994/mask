// ignore_for_file: non_constant_identifier_names

import 'package:hotkey_manager/hotkey_manager.dart';

HotKey QuitAppKey = HotKey(
  KeyCode.keyQ,
  modifiers: [KeyModifier.control],
  // Set hotkey scope (default is HotKeyScope.system)
  scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
);

HotKey SaveFileKey = HotKey(
  KeyCode.keyS,
  modifiers: [KeyModifier.control],
  // Set hotkey scope (default is HotKeyScope.system)
  scope: HotKeyScope.inapp, // Set as inapp-wide hotkey.
);
