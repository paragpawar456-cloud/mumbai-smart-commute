import 'dart:collection';

import 'models.dart';

sealed class JourneyLeg {
  const JourneyLeg();
}

class RideLeg extends JourneyLeg {
  const RideLeg(this.line, this.stationIds);

  final TransitLine line;

  /// Boarding station first, alighting station last.
  final List<String> stationIds;

  String get fromId => stationIds.first;
  String get toId => stationIds.last;
  int get stops => stationIds.length - 1;
}

class WalkLeg extends JourneyLeg {
  const WalkLeg(this.fromId, this.toId, this.minutes);

  final String fromId;
  final String toId;
  final int minutes;
}

class Journey {
  const Journey(this.legs);

  final List<JourneyLeg> legs;

  Iterable<RideLeg> get rides => legs.whereType<RideLeg>();
  int get transfers => rides.length - 1;
  int get stops => rides.fold(0, (n, r) => n + r.stops);
}

/// Station-to-station routing on the network graph (no timetable needed).
///
/// Cost is measured in stops, with a penalty per change so a route with fewer
/// changes wins unless it is much longer. Works fully offline on the phone.
class RoutePlanner {
  RoutePlanner(this.pack, {this.transferPenalty = 6}) {
    for (final line in pack.lines) {
      for (final id in line.stationIds) {
        _linesAt.putIfAbsent(id, () => []).add(line);
      }
    }
    for (final i in pack.interchanges) {
      _walks.putIfAbsent(i.fromStationId, () => []).add(i);
      _walks
          .putIfAbsent(i.toStationId, () => [])
          .add(Interchange(i.toStationId, i.fromStationId, i.walkMinutes));
    }
  }

  final DataPack pack;
  final int transferPenalty;
  final Map<String, List<TransitLine>> _linesAt = {};
  final Map<String, List<Interchange>> _walks = {};

  Journey? plan(String fromId, String toId) {
    if (fromId == toId) return null;
    if (!_linesAt.containsKey(fromId) || !_linesAt.containsKey(toId)) {
      return null;
    }

    // State = station on a line ("" line = standing on the platform/street).
    final dist = <_State, int>{};
    final prev = <_State, _State>{};
    final queue = SplayTreeSet<_Entry>((a, b) {
      final c = a.cost.compareTo(b.cost);
      return c != 0 ? c : a.seq.compareTo(b.seq);
    });
    var seq = 0;
    void push(_State s, int cost, _State? from) {
      if (cost >= (dist[s] ?? 1 << 30)) return;
      dist[s] = cost;
      if (from != null) prev[s] = from;
      queue.add(_Entry(s, cost, seq++));
    }

    push(_State(fromId, ''), 0, null);
    _State? goal;
    while (queue.isNotEmpty) {
      final e = queue.first;
      queue.remove(e);
      final s = e.state;
      if (e.cost > (dist[s] ?? 1 << 30)) continue;
      if (s.stationId == toId && s.lineId.isEmpty) {
        goal = s;
        break;
      }
      if (s.lineId.isEmpty) {
        // Board any line here (first boarding is free, later ones penalised).
        final boardCost = prev.containsKey(s) ? transferPenalty : 0;
        for (final line in _linesAt[s.stationId] ?? const <TransitLine>[]) {
          push(_State(s.stationId, line.id), e.cost + boardCost, s);
        }
        for (final w in _walks[s.stationId] ?? const <Interchange>[]) {
          push(_State(w.toStationId, ''), e.cost + (w.walkMinutes / 2).ceil(),
              s);
        }
      } else {
        // Ride one stop either way, or get off.
        final line = pack.lines.firstWhere((l) => l.id == s.lineId);
        final i = line.stationIds.indexOf(s.stationId);
        for (final j in [i - 1, i + 1]) {
          if (j >= 0 && j < line.stationIds.length) {
            push(_State(line.stationIds[j], line.id), e.cost + 1, s);
          }
        }
        push(_State(s.stationId, ''), e.cost, s);
      }
    }
    if (goal == null) return null;

    final path = <_State>[goal];
    while (prev.containsKey(path.last)) {
      path.add(prev[path.last]!);
    }
    return _toJourney(path.reversed.toList());
  }

  Journey _toJourney(List<_State> path) {
    final legs = <JourneyLeg>[];
    var i = 0;
    while (i < path.length) {
      final s = path[i];
      if (s.lineId.isNotEmpty) {
        final line = pack.lines.firstWhere((l) => l.id == s.lineId);
        final ids = <String>[s.stationId];
        while (i + 1 < path.length && path[i + 1].lineId == s.lineId) {
          i++;
          if (ids.last != path[i].stationId) ids.add(path[i].stationId);
        }
        if (ids.length > 1) legs.add(RideLeg(line, ids));
      } else if (i + 1 < path.length &&
          path[i + 1].lineId.isEmpty &&
          path[i + 1].stationId != s.stationId) {
        final w = _walks[s.stationId]!
            .firstWhere((w) => w.toStationId == path[i + 1].stationId);
        legs.add(WalkLeg(s.stationId, w.toStationId, w.walkMinutes));
      }
      i++;
    }
    return Journey(legs);
  }
}

class _State {
  const _State(this.stationId, this.lineId);
  final String stationId;
  final String lineId;

  @override
  bool operator ==(Object o) =>
      o is _State && o.stationId == stationId && o.lineId == lineId;
  @override
  int get hashCode => Object.hash(stationId, lineId);
}

class _Entry {
  const _Entry(this.state, this.cost, this.seq);
  final _State state;
  final int cost;
  final int seq;
}
