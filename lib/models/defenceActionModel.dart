class DefenceActionModel {
  final int? arg1;
  final List<int> arg2;
  final List<int> arg3;
  final List<int> attackerUsedCardIds;
  final List<int> defenderUsedCardIds;

  DefenceActionModel(
    this.arg1, // defender_defend_position
    this.arg2, // attacker_used_intercept_card_positions
    this.arg3, // defender_used_intercept_card_positions
    this.attackerUsedCardIds,
    this.defenderUsedCardIds,
  );

  Map toJson() {
    return {
      'arg1': arg1,
      'arg2': arg2,
      'arg3': arg3,
      'attackerUsedCardIds': attackerUsedCardIds,
      'defenderUsedCardIds': defenderUsedCardIds,
    };
  }
}
