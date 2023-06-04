import 'dart:convert';

class PutCardModel {
  final Map<int, int> arg1;
  final int arg2;
  final Map<int, int> arg3;
  final List<int> arg4;

  PutCardModel(
    this.arg1,
    this.arg2,
    this.arg3,
    this.arg4,
  );

  static dynamic convertToJson(PutCardModel putCardModel) {
    return jsonEncode(putCardModel.arg1);
  }
}
