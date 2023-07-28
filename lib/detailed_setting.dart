import 'package:flutter/material.dart';
import 'package:mask/detailed_setting_model.dart';
import 'package:mask/dialog_utils.dart';
import 'package:provider/provider.dart';

import 'setting_notifier.dart';

class DetailedSettingForm extends StatefulWidget {
  const DetailedSettingForm(
      {super.key, required this.width, required this.height});
  final double width;
  final double height;

  @override
  State<DetailedSettingForm> createState() => _DetailedSettingFormState();
}

class _DetailedSettingFormState extends State<DetailedSettingForm> {
  late final notifier = context.watch<SettingNotifier>();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: !notifier.detailedSettingFormShow,
        child: AnimatedOpacity(
          opacity: notifier.detailedSettingFormShow ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Card(
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(10),
              width: widget.width,
              height: widget.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "文本框大小设置:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: _widthRange(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: _heightRange(),
                  ),
                  const Text(
                    "内容设置:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: _exclude(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: _include(),
                  ),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      TextButton(
                        onPressed: () {
                          _onSubmitClicked();
                        },
                        child: const Text("确定"),
                      ),
                      TextButton(
                        onPressed: () {
                          notifier.changeSettingFormVisiblity(false);
                        },
                        child: const Text("取消"),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  static const double _width = 100;
  final TextEditingController _widthMinController = TextEditingController();
  final TextEditingController _widthMaxController = TextEditingController();

  final TextEditingController _heightMinController = TextEditingController();
  final TextEditingController _heightMaxController = TextEditingController();

  final TextEditingController _excludeTextController = TextEditingController();
  final TextEditingController _includeTextController = TextEditingController();

  final InputDecoration _decoration = const InputDecoration(
    counterText: "",
  );

  @override
  void dispose() {
    _widthMinController.dispose();
    _widthMaxController.dispose();
    _heightMinController.dispose();
    _heightMaxController.dispose();
    _excludeTextController.dispose();
    _includeTextController.dispose();
    super.dispose();
  }

  Widget _widthRange() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: _width,
          child: Text("宽度区间"),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text("min"),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            decoration: _decoration,
            maxLength: 4,
            controller: _heightMinController,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text("max"),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            decoration: _decoration,
            maxLength: 4,
            controller: _heightMaxController,
          ),
        ),
      ],
    );
  }

  Widget _heightRange() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: _width,
          child: Text("高度区间"),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text("min"),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            decoration: _decoration,
            maxLength: 4,
            controller: _widthMinController,
          ),
        ),
        // const Text("max"),
        const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text("max"),
        ),
        SizedBox(
          width: 100,
          child: TextField(
            decoration: _decoration,
            maxLength: 4,
            controller: _widthMaxController,
          ),
        ),
      ],
    );
  }

  Widget _exclude() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: _width,
          child: Text("不包括"),
        ),
        SizedBox(
          width: 200,
          child: TextField(
            decoration: _decoration,
            maxLength: 20,
            controller: _excludeTextController,
          ),
        ),
      ],
    );
  }

  Widget _include() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(
          width: _width,
          child: Text("包括"),
        ),
        SizedBox(
          width: 200,
          child: TextField(
            decoration: _decoration,
            maxLength: 20,
            controller: _includeTextController,
          ),
        ),
      ],
    );
  }

  void _onSubmitClicked() {
    late double widthMax = 0;
    late double heightMax = 0;
    late double widthMin = 0;
    late double heightMin = 0;

    if (_heightMaxController.text != "") {
      try {
        heightMax = double.parse(_heightMaxController.text);
      } catch (_) {
        SmartDialogUtils.error("数值不正确");
        return;
      }
    }

    if (_widthMaxController.text != "") {
      try {
        widthMax = double.parse(_widthMaxController.text);
      } catch (_) {
        SmartDialogUtils.error("数值不正确");
        return;
      }
    }

    if (_heightMinController.text != "") {
      try {
        heightMax = double.parse(_heightMinController.text);
      } catch (_) {
        SmartDialogUtils.error("数值不正确");
        return;
      }
    }

    if (_widthMinController.text != "") {
      try {
        heightMax = double.parse(_widthMinController.text);
      } catch (_) {
        SmartDialogUtils.error("数值不正确");
        return;
      }
    }

    if (widthMin >= widthMax || heightMin >= heightMax) {
      SmartDialogUtils.error("数值不正确");
      return;
    }

    context.read<SettingNotifier>().setModel(DetailedSettingModel(
        widthMax: widthMax,
        widthMin: widthMin,
        heightMax: heightMax,
        heightMin: heightMin,
        exclude: _excludeTextController.text,
        include: _includeTextController.text));

    notifier.changeSettingFormVisiblity(false);
  }
}
