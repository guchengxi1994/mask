// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:mask/mask.dart';
import 'package:mask/model.dart';
import 'package:mask/native.dart';
import 'package:menu_bar/menu_bar.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import 'detailed_setting.dart';
import 'hotkeys.dart';
import 'setting_notifier.dart';

const XTypeGroup typeGroup = XTypeGroup(
  label: 'images',
  extensions: <String>['jpg', 'png'],
);

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // ignore: avoid_init_to_null
  late Uint8List? data = null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future(
        () {
          NativeOcr.instance.initOcr();
        },
      ).then((value) async {
        debugPrint("[flutter] ocr inited");
        await hotKeyManager.register(
          QuitAppKey,
          keyDownHandler: (hotKey) {
            if (Platform.isWindows) {
              exit(0);
            }
          },
        );
        await hotKeyManager.register(
          SaveFileKey,
          keyDownHandler: (hotKey) {
            debugPrint("Save file");
          },
        );
        debugPrint("[flutter] hotkey inited");
      });
    });

    controller.stream.asBroadcastStream().listen((event) {
      // print(event);
      if (["装载OCR模型中", "识别中", "识别完成"].contains(event)) {
        setState(() {
          currentStatus = event;
          if (event == "装载OCR模型中") {
            progressValue = 0.2;
          }
          if (event == "识别中") {
            progressValue = 0.6;
          }
          if (event == "识别完成") {
            progressValue = 0.8;

            Future.delayed(const Duration(milliseconds: 200)).then((value) {
              setState(() {
                progressValue = 1.0;
                currentStatus = "渲染完成";
              });
            });
          }
        });
      } else {
        final OcrResults ocrResults =
            OcrResults.fromJson(jsonDecode('{"results":$event}'));
        if (ocrResults.results!.isNotEmpty) {
          int count = 0;
          for (final i in ocrResults.results!) {
            final m = MaskModel.fromResults(count, i,
                widthFactor: _widthFactor, heightFactor: _heightFactor);

            if (m != null) {
              models.add(m);
              count += 1;
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    textController.dispose();
    textController2.dispose();
    super.dispose();
  }

  final TextEditingController textController = TextEditingController();
  final TextEditingController textController2 = TextEditingController();
  final StreamController controller = StreamController<String>();
  final GlobalKey<MaskWidgetState> globalKey = GlobalKey();
  double progressValue = 0;
  String currentStatus = "";

  List<MaskModel> models = [];
  double _heightFactor = 1;
  double _widthFactor = 1;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SettingNotifier>().model;

    return MenuBarWidget(
        barStyle: const MenuStyle(
          padding: MaterialStatePropertyAll(EdgeInsets.zero),
          backgroundColor: MaterialStatePropertyAll(Color(0xFF2b2b2b)),
          maximumSize: MaterialStatePropertyAll(Size(double.infinity, 28.0)),
        ),

        // Style the menu bar buttons. Hover over [ButtonStyle] for all the options
        barButtonStyle: const ButtonStyle(
          padding:
              MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 6.0)),
          minimumSize: MaterialStatePropertyAll(Size(0.0, 32.0)),
        ),

        // Style the menu and submenu buttons. Hover over [ButtonStyle] for all the options
        menuButtonStyle: const ButtonStyle(
          minimumSize: MaterialStatePropertyAll(Size.fromHeight(36.0)),
          padding: MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0)),
        ),

        // Enable or disable the bar
        enabled: true,
        barButtons: [
          BarButton(
              text: const Text('文件', style: TextStyle(color: Colors.white)),
              submenu: SubMenu(menuItems: [
                MenuButton(
                  text: const Text('打开'),
                  icon: const Icon(Icons.file_open),
                  onTap: () async {
                    final XFile? file = await openFile(
                        acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                    if (file != null) {
                      data = await file.readAsBytes();
                      final (w, h) = await resizeImage();
                      imageWidth = w;
                      imageHeight = h;

                      setState(() {});

                      NativeOcrIsolate.instance
                          .ocr(data!, controller: controller);
                    }
                  },
                ),
                MenuButton(
                  text: const Text('保存'),
                  icon: const Icon(Icons.save),
                  shortcutText: 'Ctrl+S',
                  onTap: () {},
                ),
                MenuButton(
                  text: const Text('退出'),
                  icon: const Icon(Icons.exit_to_app),
                  shortcutText: 'Ctrl+Q',
                  onTap: () async {
                    if (Platform.isWindows) {
                      exit(0);
                    }
                  },
                ),
              ])),
          BarButton(
              text: const Text('设置', style: TextStyle(color: Colors.white)),
              submenu: SubMenu(menuItems: [
                MenuButton(
                  text: const Text('阈值设置'),
                  icon: const Icon(Icons.three_k_sharp),
                  onTap: () async {
                    final (String, String)? r = await showCupertinoDialog(
                        context: context,
                        builder: (c) {
                          return CupertinoAlertDialog(
                            title: const Text("输入阈值（正整数）"),
                            content: Material(
                              child: Column(
                                children: [
                                  TextField(
                                    decoration: const InputDecoration(
                                        hintText: "宽度阈值",
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(bottom: 0)),
                                    controller: textController,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(
                                        hintText: "高度阈值",
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(bottom: 0)),
                                    controller: textController2,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text("取消"),
                                onPressed: () {
                                  textController.text = "";
                                  Navigator.of(context).pop(null);
                                },
                              ),
                              CupertinoDialogAction(
                                child: const Text("确定"),
                                onPressed: () {
                                  Navigator.of(context).pop((
                                    textController.text,
                                    textController2.text
                                  ));
                                },
                              )
                            ],
                          );
                        });

                    if (r != null) {
                      final thres1 = int.tryParse(r.$1);
                      final thres2 = int.tryParse(r.$2);
                      if (thres1 != null &&
                          thres1 > 0 &&
                          thres2 != null &&
                          thres2 > 0) {
                        if (globalKey.currentState != null) {
                          globalKey.currentState!.filter(thres1, thres2);
                        }
                      }
                    }
                  },
                ),
                const MenuDivider(),
                MenuButton(
                    text: const Text('详细设置'),
                    icon: const Icon(Icons.details_sharp),
                    onTap: () async {
                      context
                          .read<SettingNotifier>()
                          .changeSettingFormVisiblity(true);
                    }),
                const MenuDivider(),
                MenuButton(
                    text: model == null
                        ? const Text('套用上次的设置')
                        : JustTheTooltip(
                            preferredDirection: AxisDirection.right,
                            content: SizedBox(
                              width: 300,
                              child: JsonView.map(
                                model.toJson(),
                                theme: const JsonViewTheme(
                                    backgroundColor: Colors.white),
                              ),
                            ),
                            child: const Text('套用上次的设置')),
                    icon: const Icon(Icons.upcoming),
                    onTap: model == null ? null : () {}),
              ]))
        ],
        child: Scaffold(
          body: Stack(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          height: 50,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (data != null)
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: progressValue,
                                    semanticsLabel: currentStatus,
                                  ),
                                ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(currentStatus)
                            ],
                          ),
                        ),
                        models.isEmpty
                            ? SizedBox(
                                width: imageWidth,
                                height: imageHeight,
                                child:
                                    data != null ? Image.memory(data!) : null,
                              )
                            : SizedBox(
                                width: imageWidth,
                                height: imageHeight,
                                child: MaskWidget(
                                    key: globalKey,
                                    models: models,
                                    image: Image.memory(data!)),
                              )
                      ],
                    ),
                  )),
              Positioned(
                  left: (MediaQuery.of(context).size.width - 600) / 2,
                  top: 10,
                  child: const DetailedSettingForm(
                    width: 600,
                    height: 500,
                  ))
            ],
          ),
        ));
  }

  late double imageWidth = 0;
  late double imageHeight = 0;

  Future<(double, double)> resizeImage() async {
    final (width, height) = await getImageSize(data!);
    final screenSize = MediaQuery.of(context).size;
    if (width > height) {
      // 宽大于高，以宽为主
      double _width = screenSize.width;
      double _height = screenSize.width / width * height;
      if (_height > screenSize.height) {
        final factor = screenSize.height / _height;
        _height = screenSize.height;
        _width = _width * factor;
      }
      _heightFactor = _height / height;
      _widthFactor = _width / width;
      return (_width, _height);
    } else {
      // 以高为主
      double _height = screenSize.height;
      double _width = screenSize.height / height * width;

      if (_width > screenSize.width) {
        final factor = screenSize.width / _width;
        _width = screenSize.width;
        _height = _height * factor;
      }
      _heightFactor = _height / height;
      _widthFactor = _width / width;
      return (_width, _height);
    }
  }

  Future<(int, int)> getImageSize(Uint8List data) async {
    var image = Image.memory(data);
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));

    ui.Image info = await completer.future;
    return (info.width, info.height);
  }
}
