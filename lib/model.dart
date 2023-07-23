import 'package:tuple/tuple.dart';

class MaskModel {
  final Tuple2<int, int> topLeft;
  final Tuple2<int, int> bottomRight;
  final int id;
  bool visible = false;
  late String content = "";

  MaskModel(
      {required this.bottomRight,
      required this.topLeft,
      required this.id,
      this.content = ""}) {
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
}
