import 'dart:async';
import 'package:CodeOfFlow/bloc/bg_color/bg_color_event.dart';

class DropAllowBloc {
  int _bg_color = 0xFFFFFFFF; // _から始まる変数はプライベート変数

  final _bgColorStateController = StreamController<int>();
  // Input
  StreamSink<int> get _intCounter => _bgColorStateController.sink;
  // Output
  Stream<int> get bg_color => _bgColorStateController.stream;

  final _bgColorEventController = StreamController<CounterEvent>();
  // Input
  Sink<CounterEvent> get counterEventSink => _bgColorEventController.sink;

  DropAllowBloc() {
    _bgColorEventController.stream.listen(_mapEventToState);
  }

  // business logic

  void _mapEventToState(CounterEvent event) {
    if (event is DropAllowedEvent) {
      _bg_color = 0xFF0088FF;
    } else if (event is DropDeniedEvent) {
      _bg_color = 0xFFBB0066;
    } else {
      _bg_color = 0xFFFFFFFF;
    }
    _intCounter.add(_bg_color);
  }

  void dispose() {
    _bgColorStateController.close();
    _bgColorEventController.close();
  }
}
