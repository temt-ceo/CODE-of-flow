abstract class AttackEvent {}

class AttackAllowedEvent extends AttackEvent {}

class BattlingEvent extends AttackEvent {}

class BattleFinishingEvent extends AttackEvent {}

class BattleFinishedEvent extends AttackEvent {}

class AttackNotAllowedEvent extends AttackEvent {}

class CanUseTriggerIndex1Event extends AttackEvent {}

class CanUseTriggerIndex2Event extends AttackEvent {}

class CanUseTriggerIndex3Event extends AttackEvent {}

class CanUseTriggerIndex4Event extends AttackEvent {}
