class GameObject {
  final int turn;
  final bool isFirst;
  final bool isFirstTurn;
  final String matchedTime;
  final bool gameStarted;
  final String? lastTimeTurnend;
  final int you;
  int yourCp;
  final dynamic yourFieldUnit;
  final int yourDefendableUnitLength;
  final int opponentDefendableUnitLength;
  final dynamic yourFieldUnitAction;
  final dynamic yourFieldUnitBpAmountOfChange;
  final dynamic yourHand;
  final int yourLife;
  final List<dynamic> yourRemainDeck;
  final dynamic yourTriggerCards;
  final int opponent;
  final int opponentCp;
  final dynamic opponentFieldUnit;
  final dynamic opponentFieldUnitAction;
  final dynamic opponentFieldUnitBpAmountOfChange;
  final int opponentHand;
  final int opponentLife;
  final int opponentRemainDeck;
  final int opponentTriggerCards;
  final dynamic yourAttackingCard;
  final dynamic enemyAttackingCard;

  GameObject(
    this.turn,
    this.isFirst,
    this.isFirstTurn,
    this.matchedTime,
    this.gameStarted,
    this.lastTimeTurnend,
    this.you,
    this.yourCp,
    this.yourFieldUnit,
    this.yourDefendableUnitLength,
    this.opponentDefendableUnitLength,
    this.yourFieldUnitAction,
    this.yourFieldUnitBpAmountOfChange,
    this.yourHand,
    this.yourLife,
    this.yourRemainDeck,
    this.yourTriggerCards,
    this.opponent,
    this.opponentCp,
    this.opponentFieldUnit,
    this.opponentFieldUnitAction,
    this.opponentFieldUnitBpAmountOfChange,
    this.opponentHand,
    this.opponentLife,
    this.opponentRemainDeck,
    this.opponentTriggerCards,
    this.yourAttackingCard,
    this.enemyAttackingCard,
  );

  static dynamic getOtherGameInfo() {
    return GameObject(1, true, true, '1', true, '1', 1, 1, {}, 0, 0, 1, 1,
        {1: 16}, 1, [], {}, 1, 1, {}, 1, 1, 1, 1, 1, 1, null, null);
  }
}
