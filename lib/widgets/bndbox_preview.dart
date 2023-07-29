import 'package:flutter/material.dart';
import 'package:mask/notifiers/custom_mask_notifier.dart';
import 'package:provider/provider.dart';

class BndBoxPreviewWidget extends StatelessWidget {
  const BndBoxPreviewWidget({Key? key, required this.left, required this.top})
      : super(key: key);
  final double left;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: left,
        top: top,
        child: Opacity(
          opacity: 0.7,
          child: Container(
            color: Colors.blueAccent,
            width: context.select<CustomMaskNotifier, double>(
                (value) => value.bndboxPreviewWidth),
            height: context.select<CustomMaskNotifier, double>(
                (value) => value.bndboxPreviewHeight),
          ),
        ));
  }
}
