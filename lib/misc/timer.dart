import 'dart:async';

// Timers are naturally asynchronous
void main() {
  // Once and for all
  var timer = Timer(Duration(seconds: 3), () {
    print("Timer 1 elapsed");
  });

  // Periodic timer
  var counter = 3;
  Timer.periodic(Duration(seconds: 1), (timer) {
    print(timer.tick);
    counter--;
    if (counter == 0) {
      print('Timer 2 cancelled');
      timer.cancel();
    }
  });
}
