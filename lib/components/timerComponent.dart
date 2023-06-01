import 'dart:async';

class TimerComponent {
  final events = StreamController<int>();
  int _counter = 0;

  late Timer _timer;
  void _startTimer(startTime, cb) {
    _counter = startTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        _counter--;
        if (_counter == 0 && cb != null) {
          cb();
        }
      } else {
        _timer.cancel();
      }
      events.add(_counter);
    });
  }

  void countdownStart(startTime, cb) {
    events.add(startTime);
    _startTimer(startTime, cb);
  }

  void dispose() {
    events.close();
  }
}
