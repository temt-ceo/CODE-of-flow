import 'dart:async';
import 'package:CodeOfFlow/bloc/attack_status/attack_status_event.dart';

class AttackStatusBloc {
  int _attack_status = 0;

  final _canAttackStateController = StreamController<int>.broadcast();
  // Input
  StreamSink<int> get _bool => _canAttackStateController.sink;
  // Output
  Stream<int> get attack_stream => _canAttackStateController.stream;

  final _canAttackEventController = StreamController<AttackEvent>();
  // Input
  Sink<AttackEvent> get canAttackEventSink => _canAttackEventController.sink;

  AttackStatusBloc() {
    // final myStream = _canAttackEventController.stream.asBroadcastStream();
    // myStream.listen(_mapEventToState);
    _canAttackEventController.stream.listen(_mapEventToState);
  }
  // business logic

  void _mapEventToState(AttackEvent event) {
    if (event is Index1AttackAllowedEvent) {
      _attack_status = 31;
    } else if (event is Index2AttackAllowedEvent) {
      _attack_status = 32;
    } else if (event is Index3AttackAllowedEvent) {
      _attack_status = 33;
    } else if (event is Index4AttackAllowedEvent) {
      _attack_status = 34;
    } else if (event is Index5AttackAllowedEvent) {
      _attack_status = 35;
    } else if (event is BattlingEvent) {
      _attack_status = 2;
    } else if (event is BattleFinishingEvent) {
      _attack_status = 3;
    } else if (event is BattleFinishedEvent) {
      _attack_status = 4;
    } else if (event is CanUseTriggerIndex1Event) {
      _attack_status = 11;
    } else if (event is CanUseTriggerIndex2Event) {
      _attack_status = 12;
    } else if (event is CanUseTriggerIndex3Event) {
      _attack_status = 13;
    } else if (event is CanUseTriggerIndex4Event) {
      _attack_status = 14;
    } else if (event is CanNotUseTriggerEvent) {
      _attack_status = 15;
    } else if (event is ButtonTapepingEvent) {
      _attack_status = 19;
    } else if (event is ButtonTapedEvent) {
      _attack_status = 20;
    } else if (event is DisableTriggerIndex1Event) {
      _attack_status = 21;
    } else if (event is DisableTriggerIndex2Event) {
      _attack_status = 22;
    } else if (event is DisableTriggerIndex3Event) {
      _attack_status = 23;
    } else if (event is DisableTriggerIndex4Event) {
      _attack_status = 24;
    } else {
      _attack_status = 0;
    }
    _bool.add(_attack_status);
  }

  void dispose() {
    _canAttackStateController.close();
    _canAttackEventController.close();
  }
}
