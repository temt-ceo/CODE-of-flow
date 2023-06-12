class TurnEndModel {
  final bool arg1;

  TurnEndModel(
    this.arg1,
  );

  Map toJson() {
    return {
      'arg1': arg1,
    };
  }
}
