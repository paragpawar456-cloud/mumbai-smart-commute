/// Transit data shipped to the phone as one versioned "data pack".
/// Everything here is static or scheduled data; nothing is live.
library;

import '../../lastmile/domain/lastmile_models.dart';

enum TransitMode { suburban, metro, mono }

TransitMode _mode(String s) => TransitMode.values.firstWhere(
      (m) => m.name == s,
      orElse: () => TransitMode.suburban,
    );

class Station {
  const Station({
    required this.id,
    required this.nameEn,
    this.nameMr,
    this.nameHi,
    required this.lat,
    required this.lng,
    required this.sourceId,
  });

  factory Station.fromJson(Map<String, dynamic> j) => Station(
        id: j['station_id'] as String,
        nameEn: j['name_en'] as String,
        nameMr: _str(j['name_mr']),
        nameHi: _str(j['name_hi']),
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        sourceId: j['source_id'] as String? ?? '',
      );

  final String id;
  final String nameEn;
  final String? nameMr;
  final String? nameHi;
  final double lat;
  final double lng;
  final String sourceId;

  String name(String languageCode) => switch (languageCode) {
        'mr' => nameMr ?? nameEn,
        'hi' => nameHi ?? nameEn,
        _ => nameEn,
      };
}

class TransitLine {
  const TransitLine({
    required this.id,
    required this.operator,
    required this.mode,
    required this.nameEn,
    required this.color,
    required this.stationIds,
    required this.sourceId,
  });

  factory TransitLine.fromJson(Map<String, dynamic> j) => TransitLine(
        id: j['route_id'] as String,
        operator: j['operator'] as String,
        mode: _mode(j['mode'] as String),
        nameEn: j['name_en'] as String,
        color: _str(j['color']),
        stationIds: (j['station_sequence'] as String)
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        sourceId: j['source_id'] as String? ?? '',
      );

  final String id;
  final String operator;
  final TransitMode mode;
  final String nameEn;
  final String? color;
  final List<String> stationIds;
  final String sourceId;
}

/// A walking transfer between two different stations (e.g. metro ↔ suburban).
class Interchange {
  const Interchange(this.fromStationId, this.toStationId, this.walkMinutes);

  factory Interchange.fromJson(Map<String, dynamic> j) => Interchange(
        j['from_station_id'] as String,
        j['to_station_id'] as String,
        (j['walk_minutes'] as num).toInt(),
      );

  final String fromStationId;
  final String toStationId;
  final int walkMinutes;
}

enum Direction { up, down }

class Trip {
  const Trip({
    required this.id,
    required this.lineId,
    this.trainNumber,
    required this.direction,
    required this.serviceDays,
    required this.trainType,
    required this.ac,
    required this.ladiesSpecial,
    required this.validFrom,
    this.validTo,
    required this.sourceId,
    this.originName,
    this.headsign,
  });

  factory Trip.fromJson(Map<String, dynamic> j) => Trip(
        id: j['trip_id'] as String,
        lineId: j['route_id'] as String,
        trainNumber: _str(j['train_number']),
        direction: j['direction'] == 'up' ? Direction.up : Direction.down,
        serviceDays: (j['service_days'] as String).toUpperCase(),
        trainType: j['train_type'] as String? ?? 'slow',
        ac: _bool(j['ac']),
        ladiesSpecial: _bool(j['ladies_special']),
        validFrom: DateTime.parse(j['valid_from'] as String),
        validTo: _str(j['valid_to']) == null
            ? null
            : DateTime.parse(j['valid_to'] as String),
        sourceId: j['source_id'] as String? ?? '',
        originName: _str(j['origin_name']),
        headsign: _str(j['headsign']),
      );

  final String id;
  final String lineId;
  final String? trainNumber;
  final Direction direction;

  /// MON-SAT, MON-FRI, SAT, SUN, DAILY or HOL.
  final String serviceDays;
  final String trainType;
  final bool ac;
  final bool ladiesSpecial;
  final DateTime validFrom;
  final DateTime? validTo;
  final String sourceId;

  /// Where the train starts and ends as printed in the timetable, which can
  /// be beyond the stations in the app (e.g. "Kasara", "Karjat").
  final String? originName;
  final String? headsign;

  bool runsOn(DateTime date, {bool holiday = false}) {
    final d = DateTime(date.year, date.month, date.day);
    if (d.isBefore(DateTime(validFrom.year, validFrom.month, validFrom.day))) {
      return false;
    }
    if (validTo != null && d.isAfter(validTo!)) return false;
    final wd = date.weekday; // 1 = Mon … 7 = Sun
    // Suburban trains run the Sunday timetable on public holidays.
    final effectiveSunday = wd == DateTime.sunday || holiday;
    return switch (serviceDays) {
      'DAILY' => true,
      'MON-SAT' => !effectiveSunday,
      'MON-FRI' => !effectiveSunday && wd != DateTime.saturday,
      'SAT' => !effectiveSunday && wd == DateTime.saturday,
      'SUN' || 'HOL' => effectiveSunday,
      _ => false,
    };
  }
}

class StopTime {
  const StopTime(this.tripId, this.seq, this.stationId, this.arrival,
      this.departure, this.platform);

  /// Compact row: [trip_id, seq, station_id, arrival, departure, platform].
  factory StopTime.fromRow(List<dynamic> r) => StopTime(
        r[0] as String,
        (r[1] as num).toInt(),
        r[2] as String,
        _minutes(_str(r[3])),
        _minutes(_str(r[4]))!,
        _str(r.length > 5 ? r[5] : null),
      );

  final String tripId;
  final int seq;
  final String stationId;

  /// Minutes after midnight; may exceed 1440 for after-midnight runs.
  final int? arrival;
  final int departure;
  final String? platform;
}

class DataSourceInfo {
  const DataSourceInfo({
    required this.id,
    required this.name,
    required this.licence,
    this.attribution,
    this.url,
  });

  factory DataSourceInfo.fromJson(Map<String, dynamic> j) => DataSourceInfo(
        id: j['source_id'] as String,
        name: j['name'] as String,
        licence: j['licence'] as String? ?? '',
        attribution: _str(j['attribution']),
        url: _str(j['url']),
      );

  final String id;
  final String name;
  final String licence;
  final String? attribution;
  final String? url;
}

class DataPack {
  DataPack({
    required this.version,
    required this.generatedAt,
    required this.stations,
    required this.lines,
    required this.interchanges,
    required this.trips,
    required this.stopTimes,
    required this.sources,
    this.lastMile = const LastMileData(),
  }) : stationById = {for (final s in stations) s.id: s};

  factory DataPack.fromJson(Map<String, dynamic> j) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) =>
        ((j[key] as List?) ?? const [])
            .map((e) => f((e as Map).cast<String, dynamic>()))
            .toList();
    return DataPack(
      version: (j['version'] as num).toInt(),
      generatedAt: DateTime.parse(j['generated_at'] as String),
      stations: list('stations', Station.fromJson),
      lines: list('lines', TransitLine.fromJson),
      interchanges: list('interchanges', Interchange.fromJson),
      trips: list('trips', Trip.fromJson),
      stopTimes: ((j['stop_times'] as List?) ?? const [])
          .map((r) => StopTime.fromRow(r as List))
          .toList(),
      sources: list('sources', DataSourceInfo.fromJson),
      lastMile: LastMileData.fromPackJson(j),
    );
  }

  final int version;
  final DateTime generatedAt;
  final List<Station> stations;
  final List<TransitLine> lines;
  final List<Interchange> interchanges;
  final List<Trip> trips;
  final List<StopTime> stopTimes;
  final List<DataSourceInfo> sources;
  final Map<String, Station> stationById;
  final LastMileData lastMile;

  bool get hasTimetable => trips.isNotEmpty && stopTimes.isNotEmpty;
}

String? _str(Object? v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

bool _bool(Object? v) => v == true || v.toString().toUpperCase() == 'TRUE';

int? _minutes(String? hhmm) {
  if (hhmm == null) return null;
  final parts = hhmm.split(':');
  if (parts.length != 2) throw FormatException('Bad time $hhmm');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

String formatMinutes(int m) {
  final h = (m ~/ 60) % 24;
  return '${h.toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
}

/// Where a train is going: the station name in the user's language when the
/// train ends at a station in the app, else as printed in the timetable.
String trainHeadsign(Trip trip, DataPack pack, String terminusId, String lang) {
  final end = pack.stationById[terminusId];
  final h = trip.headsign;
  if (h == null || end == null || end.nameEn.toLowerCase() == h.toLowerCase()) {
    return end?.name(lang) ?? h ?? terminusId;
  }
  return h;
}
