import 'dart:async';
import 'package:CodeOfFlow/bloc/counter/counter_event.dart';

class CounterBloc {
  int _counter = 0; // _から始まる変数はプライベート変数

  final _counterStateController = StreamController<int>();
  // Input
  StreamSink<int> get _intCounter => _counterStateController.sink;
  // Output
  Stream<int> get counter => _counterStateController.stream;

  final _counterEventController = StreamController<CounterEvent>();
  // Input
  Sink<CounterEvent> get counterEventSink => _counterEventController.sink;

  CounterBloc() {
    _counterEventController.stream.listen(_mapEventToState);
  }

  // business logic

  void _mapEventToState(CounterEvent event) {
    if (event is IncrementEvent) {
      _counter++;
    } else {
      _counter--;
    }
    _intCounter.add(_counter);
  }

  void dispose() {
    _counterStateController.close();
    _counterEventController.close();
  }
}
