import '../../transit/domain/models.dart';

enum TrainPhase { notStarted, atStation, moving, finished }

/// Where a train should be according to its timetable. This is never a live
/// position: real trains run late, and the app says so.
class TrainPosition {
  const TrainPosition(this.phase, this.index, [this.fraction = 0]);

  final TrainPhase phase;

  /// The station the train is at, or the one it last left when moving.
  final int index;

  /// 0 at [index], 1 at the next station. Only used while moving.
  final double fraction;

  /// Position along the list of stops, e.g. 2.5 = halfway from stop 2 to 3.
  double get progress => index + fraction;
}

int _arr(StopTime s) => s.arrival ?? s.departure;

/// [nowMinute] is minutes after midnight, with seconds as a fraction.
TrainPosition trainPositionAt(List<StopTime> stops, double nowMinute) {
  if (stops.isEmpty) return const TrainPosition(TrainPhase.finished, 0);
  if (nowMinute < _arr(stops.first)) {
    return const TrainPosition(TrainPhase.notStarted, 0);
  }
  for (var i = 0; i < stops.length; i++) {
    final s = stops[i];
    if (nowMinute >= _arr(s) && nowMinute < s.departure) {
      return TrainPosition(TrainPhase.atStation, i);
    }
    if (i == stops.length - 1) break;
    final next = stops[i + 1];
    if (nowMinute >= s.departure && nowMinute < _arr(next)) {
      final span = _arr(next) - s.departure;
      return TrainPosition(TrainPhase.moving, i,
          span <= 0 ? 0 : (nowMinute - s.departure) / span);
    }
  }
  final last = stops.length - 1;
  if (nowMinute < _arr(stops[last]) + 1) {
    return TrainPosition(TrainPhase.atStation, last);
  }
  return TrainPosition(TrainPhase.finished, last);
}

/// Minutes until the train reaches stop [index] (negative once it has left).
double minutesUntil(List<StopTime> stops, int index, double nowMinute) =>
    _arr(stops[index]) - nowMinute;

/// Minutes after midnight for [t], including seconds.
double minuteOfDay(DateTime t) => t.hour * 60 + t.minute + t.second / 60;
