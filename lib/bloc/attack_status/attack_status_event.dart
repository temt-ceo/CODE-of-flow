abstract class AttackEvent {}

class AttackAllowedEvent extends AttackEvent {}

class BattlingEvent extends AttackEvent {}

class BattleFinishedEvent extends AttackEvent {}

class AttackNotAllowedEvent extends AttackEvent {}
