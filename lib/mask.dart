import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mask/model.dart';
import 'package:provider/provider.dart';

class MaskNotifier extends ChangeNotifier {
  final List<bool> visibles;

  MaskNotifier({required this.visibles});

  bool getVisible(int index) {
    return visibles[index];
  }

  changeVisible(int index, bool b) {
    visibles[index] = b;
    notifyListeners();
  }
}

class MaskWidget extends StatefulWidget {
  const MaskWidget({Key? key, required this.models, required this.image})
      : super(key: key);
  final List<MaskModel> models;
  final Image image;

  @override
  State<MaskWidget> createState() => _MaskWidgetState();
}

class _MaskWidgetState extends State<MaskWidget> {
  late final MaskNotifier maskNotifier;

  @override
  void initState() {
    super.initState();
    maskNotifier =
        MaskNotifier(visibles: List.filled(widget.models.length, false));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => maskNotifier,
      builder: (ctx, child) {
        return Stack(
          children: [
            SizedBox.expand(
              child: widget.image,
            ),
            ..._masks(ctx)
          ],
        );
      },
    );
  }

  List<Widget> _masks(BuildContext ctx) {
    List<Widget> result = [];
    for (final i in widget.models) {
      result.add(Positioned(
          left: i.left,
          top: i.top,
          width: i.width,
          height: i.height,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: ctx.watch<MaskNotifier>().getVisible(i.id) ? 0 : 1.0,
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
                    color: Colors.white.withOpacity(0),
                    child: Center(
                      child: Text("Mask ${i.id}"),
                    ),
                  ),
                ),
              ),
            ),
          )));
    }

    return result;
  }
}
