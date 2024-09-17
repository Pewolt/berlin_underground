import 'package:berlin_underground/models/line.dart';
import 'package:berlin_underground/models/station.dart';

abstract class Disruption {
  int remainingTurns;

  Disruption(this.remainingTurns);

  void decrementTurns() {
    remainingTurns--;
  }

  bool isExpired() {
    return remainingTurns <= 0;
  }
}

class LineClosure extends Disruption {
  Line affectedLine;

  LineClosure(this.affectedLine, int duration) : super(duration);
}

class StationClosure extends Disruption {
  Station affectedStation;

  StationClosure(this.affectedStation, int duration) : super(duration);
}

class Delay extends Disruption {
  Station affectedStation;
  int delayTime;

  Delay(this.affectedStation, this.delayTime) : super(1); // Einmalige Verspätung
}
