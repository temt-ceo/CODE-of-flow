abstract class AttackEvent {}

class AttackAllowedEvent extends AttackEvent {}

class AttackingEvent extends AttackEvent {}

class AttackFinishedEvent extends AttackEvent {}

class AttackNotAllowedEvent extends AttackEvent {}
