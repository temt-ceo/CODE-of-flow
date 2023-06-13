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
    if (event is AttackAllowedEvent) {
      _attack_status = 1;
    } else if (event is BattlingEvent) {
      _attack_status = 2;
    } else if (event is BattleFinishedEvent) {
      _attack_status = 3;
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
