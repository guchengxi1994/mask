import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mask/notifiers/setting_notifier.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await hotKeyManager.unregisterAll();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SettingNotifier())],
      child: MaterialApp(
        navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(),
        debugShowCheckedModeBanner: false,
        title: 'Mask',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const App(),
      ),
    );
  }
}
