class DefenceActionModel {
  final int? arg1;
  final List<int> arg2;
  final List<int> arg3;

  DefenceActionModel(
    this.arg1, // opponent_defend_position
    this.arg2,
    this.arg3,
  );

  Map toJson() {
    return {
      'arg1': arg1,
      'arg2': arg2,
      'arg3': arg3,
    };
  }
}
