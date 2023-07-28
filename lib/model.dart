// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:mask/detailed_setting_model.dart';
import 'package:tuple/tuple.dart';

class OcrResults {
  List<Results>? results;

  OcrResults({this.results});

  OcrResults.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? box;
  String? text;

  Results({this.box, this.text});

  Results.fromJson(Map<String, dynamic> json) {
    box = json['box'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['box'] = box;
    data['text'] = text;
    return data;
  }
}

class MaskModel {
  final Tuple2<int, int> topLeft;
  final Tuple2<int, int> bottomRight;
  final int id;
  bool visible = false;
  late String content = "";
  final String text;

  MaskModel(
      {required this.bottomRight,
      required this.topLeft,
      required this.id,
      this.content = "",
      required this.text}) {
    assert(
        bottomRight.item1 > topLeft.item1 && bottomRight.item2 > topLeft.item2);
    if (content == "") {
      content = "Mask $id";
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! MaskModel) {
      return false;
    }
    return other.bottomRight == bottomRight &&
        other.topLeft == topLeft &&
        other.id == id;
  }

  double get width => (bottomRight.item2 - topLeft.item2).toDouble();
  double get height => (bottomRight.item1 - topLeft.item1).toDouble();
  double get left => topLeft.item2.toDouble();
  double get top => topLeft.item1.toDouble();

  @override
  int get hashCode => topLeft.hashCode + bottomRight.hashCode + id.hashCode;

  @override
  String toString() {
    return "[id] $id, [top-left] $topLeft, [bottom-right] $bottomRight";
  }

  bool satisfied({int thres1 = 30, int thres2 = 30}) {
    return width >= thres1 && height >= thres2;
  }

  bool satisfiedComplex(DetailedSettingModel model) {
    return width > model.widthMin! &&
        width < model.widthMax! &&
        height > model.heightMin! &&
        height < model.heightMax! &&
        text.contains(model.include!) &&
        (model.exclude == "" ? true : text.contains(model.exclude!));
  }

  static MaskModel? fromResults(int id, Results results,
      {double widthFactor = 1, double heightFactor = 1}) {
    String position = results.box ?? "";
    List<String> _positions = position.split(" ");
    if (_positions.length < 8) {
      return null;
    }

    final leftTop = Tuple2(
      (int.parse(_positions[1]) * heightFactor).ceil(),
      (int.parse(_positions[0]) * widthFactor).ceil(),
    );
    final rightBottom = Tuple2(
      (int.parse(_positions[5]) * heightFactor).ceil(),
      (int.parse(_positions[4]) * widthFactor).ceil(),
    );

    return MaskModel(
        bottomRight: rightBottom,
        topLeft: leftTop,
        id: id,
        text: results.text ?? "");
  }
}
