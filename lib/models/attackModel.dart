class FieldUnits {
  final int? position1;
  final int? position2;
  final int? position3;
  final int? position4;
  final int? position5;
  FieldUnits(
    this.position1,
    this.position2,
    this.position3,
    this.position4,
    this.position5,
  );
  Map toJson() => {
        '1': position1,
        '2': position2,
        '3': position3,
        '4': position4,
        '5': position5,
      };
}

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

class AttackModel {
  final int arg1;
  final int? arg2;
  final TriggerCards arg3;
  final List<int> arg4;
  final List<int> usedCardIds;

  AttackModel(
    this.arg1,
    this.arg2,
    this.arg3,
    this.arg4,
    this.usedCardIds,
  );

  Map toJson() {
    Map arg3Json = arg3.toJson();
    return {
      'arg1': arg1,
      'arg2': arg2,
      'arg3': arg3Json,
      'arg4': arg4,
      'usedCardIds': usedCardIds,
    };
  }
}
