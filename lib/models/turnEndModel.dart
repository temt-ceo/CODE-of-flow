class TriggerCards {
  final int? position1;
  final int? position2;
  final int? position3;
  final int? position4;
  TriggerCards(
    this.position1,
    this.position2,
    this.position3,
    this.position4,
  );
  Map toJson() => {
        '1': position1,
        '2': position2,
        '3': position3,
        '4': position4,
      };
}

class TurnEndModel {
  final bool arg1;
  final TriggerCards arg2;

  TurnEndModel(
    this.arg1,
    this.arg2,
  );

  Map toJson() {
    return {
      'arg1': arg1,
      'arg2': arg2,
    };
  }
}
