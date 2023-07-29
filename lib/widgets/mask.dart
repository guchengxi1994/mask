// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mask/models/model.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:super_context_menu/super_context_menu.dart';
import '../notifiers/notifier.dart';

class MaskWidget extends StatefulWidget {
  const MaskWidget({Key? key, required this.models, required this.image})
      : super(key: key);
  final List<MaskModel> models;
  final Image image;

  @override
  State<MaskWidget> createState() => MaskWidgetState();
}

class MaskWidgetState extends State<MaskWidget> {
  late final MaskNotifier maskNotifier;

  filter(int widthThres, int heightThres) {
    maskNotifier.filter(widthThres, heightThres);
  }

  @override
  void initState() {
    super.initState();
    maskNotifier = MaskNotifier(models: widget.models);
  }

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => maskNotifier,
      builder: (ctx, child) {
        return Screenshot(
            controller: screenshotController,
            child: Stack(
              children: [
                SizedBox.expand(
                  child: widget.image,
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: ElevatedButton(
                        onPressed: () async {
                          screenshotController.capture().then((value) {
                            if (value != null) {
                              showGeneralDialog(
                                  context: context,
                                  pageBuilder: (c, a, b) {
                                    return Center(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: 600,
                                            height: 600,
                                            child: Image.memory(value),
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("close"))
                                        ],
                                      ),
                                    );
                                  });
                            }
                          });
                        },
                        child: const Text("Save Image"))),
                ..._masks(ctx)
              ],
            ));
      },
    );
  }

  final TextEditingController controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<Widget> _masks(BuildContext ctx) {
    List<Widget> result = [];
    final models = ctx.watch<MaskNotifier>().maskModels;

    for (final i in models) {
      bool visible = ctx.read<MaskNotifier>().getVisible(i.id);

      result.add(Positioned(
        left: i.left,
        top: i.top,
        width: i.width,
        height: i.height,
        child: ContextMenuWidget(
            child: Container(
                decoration:
                    BoxDecoration(border: visible ? Border.all() : null),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: visible ? 0 : 1.0,
                  child: MouseRegion(
                    onEnter: (event) {
                      ctx.read<MaskNotifier>().changeVisible(i.id, true);
                    },
                    onExit: (event) {
                      ctx.read<MaskNotifier>().changeVisible(i.id, false);
                    },
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0),
                          ),
                          child: Center(
                            child: Text(i.content),
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
            menuProvider: (_) {
              return Menu(
                children: [
                  MenuAction(
                      image: MenuImage.icon(Icons.cancel_sharp),
                      title: 'Delete',
                      callback: () {
                        ctx.read<MaskNotifier>().removeById(i.id);
                      }),
                  MenuAction(
                      image: MenuImage.icon(Icons.change_circle),
                      title: 'Modify Content',
                      callback: () async {
                        controller.text = i.content;
                        final r = await showCupertinoDialog(
                            context: context,
                            builder: (c) {
                              return CupertinoAlertDialog(
                                title: const Text("输入想要的内容"),
                                content: Material(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(bottom: 0)),
                                    controller: controller,
                                  ),
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text("取消"),
                                    onPressed: () {
                                      controller.text = "";
                                      Navigator.of(context).pop("");
                                    },
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text("确定"),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(controller.text);
                                    },
                                  )
                                ],
                              );
                            });

                        if (r != "") {
                          // ignore: use_build_context_synchronously
                          ctx.read<MaskNotifier>().changeContent(i.id, r);
                        }
                      }),
                ],
              );
            }),
      ));
    }

    return result;
  }
}
