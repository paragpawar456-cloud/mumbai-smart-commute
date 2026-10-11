import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/data_source_label.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/source_badge.dart';
import '../../settings/settings_controller.dart';
import '../../transit/domain/models.dart';
import '../../transit/domain/timetable.dart';
import '../domain/train_tracker.dart';

/// "Where is my train": the train moving down its line by the timetable.
/// Positions are scheduled, never live, and the screen says so.
class WhereIsMyTrainScreen extends ConsumerStatefulWidget {
  const WhereIsMyTrainScreen({super.key, required this.run, required this.pack});

  final TrainRun run;
  final DataPack pack;

  @override
  ConsumerState<WhereIsMyTrainScreen> createState() => _WhereIsMyTrainState();
}

class _WhereIsMyTrainState extends ConsumerState<WhereIsMyTrainScreen>
    with SingleTickerProviderStateMixin {
  static const rowHeight = 64.0;
  late final AnimationController _pulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600));
  final _scroll = ScrollController();
  Timer? _tick;
  late DateTime _now = ref.read(clockProvider)();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1),
        (_) => setState(() => _now = ref.read(clockProvider)()));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ref.read(settingsProvider).reducedMotion) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _pulse.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _name(String id, String lang) =>
      widget.pack.stationById[id]?.name(lang) ?? id;

  /// True when the timetable says the train starts before the first station
  /// the app knows about (e.g. a Kasara train seen from Kalyan).
  bool _startsBeyondPack(TrainRun run) {
    final origin = run.trip.originName;
    final first = widget.pack.stationById[run.originId]?.nameEn;
    return origin != null &&
        first != null &&
        origin.toLowerCase() != first.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final run = widget.run;
    final stops = run.stops;
    final nowMin = minuteOfDay(_now);
    final pos = trainPositionAt(stops, nowMin);
    final board = _name(stops[run.boardIndex].stationId, lang);
    final alight = _name(stops[run.alightIndex].stationId, lang);
    final toBoard = minutesUntil(stops, run.boardIndex, nowMin);
    final toAlight = minutesUntil(stops, run.alightIndex, nowMin);
    final reducedMotion = ref.watch(settingsProvider).reducedMotion;

    final (headline, sub) = switch (pos.phase) {
      TrainPhase.finished => (l.trainFinished(_name(run.terminusId, lang)), ''),
      _ when pos.progress < run.boardIndex => (
          toBoard < 1 ? l.trainArrivingNow(board) : l.trainReachesIn(board, toBoard.ceil()),
          pos.phase == TrainPhase.notStarted
              ? _startsBeyondPack(run)
                  ? l.trainComingFrom(run.trip.originName!,
                      _name(run.originId, lang), formatMinutes(stops.first.departure))
                  : l.trainStartsAt(_name(run.originId, lang),
                      formatMinutes(stops.first.departure))
              : pos.phase == TrainPhase.atStation
                  ? l.trainNowAt(_name(stops[pos.index].stationId, lang))
                  : l.trainNowBetween(_name(stops[pos.index].stationId, lang),
                      _name(stops[pos.index + 1].stationId, lang)),
        ),
      _ when pos.phase == TrainPhase.atStation && pos.index == run.boardIndex =>
        (l.trainAtNow(board), l.trainReachesIn(alight, math.max(1, toAlight.ceil()))),
      _ when toAlight > 0 => (
          l.trainReachesIn(alight, toAlight.ceil()),
          l.trainLeftAgo(board, (-toBoard).floor().clamp(0, 999)),
        ),
      _ => (l.trainReached(alight), ''),
    };

    if (!_scrolled) {
      _scrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scroll.hasClients) return;
        final target = (pos.progress * rowHeight - 120)
            .clamp(0.0, _scroll.position.maxScrollExtent);
        _scroll.jumpTo(target);
      });
    }

    final trainColor = run.trip.trainType == 'fast' ? AppColors.bus : AppColors.localTrain;

    return Scaffold(
      appBar: AppBar(title: Text(l.whereIsMyTrain)),
      body: Column(children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [trainColor, trainColor.withValues(alpha: 0.75)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${formatMinutes(run.departure)} · ${l.towards(trainHeadsign(run.trip, widget.pack, run.terminusId, lang))} · '
                '${run.trip.trainType == 'fast' ? l.fastTrain : l.slowTrain}',
                style: text.labelLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(headline,
                  key: const Key('trainHeadline'),
                  style: text.headlineSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              if (sub.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(sub, style: text.bodyMedium?.copyWith(color: Colors.white)),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const SourceBadge(kind: DataSourceKind.scheduled),
            const SizedBox(width: 8),
            Expanded(child: Text(l.scheduledNotLive, style: text.bodySmall)),
          ]),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.only(bottom: 24),
            child: SizedBox(
              height: stops.length * rowHeight,
              child: Stack(children: [
                // The track: done part solid, the rest faded.
                Positioned(
                  left: 38,
                  top: rowHeight / 2,
                  height: (stops.length - 1) * rowHeight,
                  width: 6,
                  child: Container(color: trainColor.withValues(alpha: 0.2)),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: pos.progress),
                  duration: Duration(milliseconds: reducedMotion ? 0 : 900),
                  builder: (_, p, _) => Positioned(
                    left: 38,
                    top: rowHeight / 2,
                    height: p * rowHeight,
                    width: 6,
                    child: Container(color: trainColor),
                  ),
                ),
                for (var i = 0; i < stops.length; i++)
                  Positioned(
                    top: i * rowHeight,
                    left: 0,
                    right: 0,
                    height: rowHeight,
                    child: _StopRow(
                      name: _name(stops[i].stationId, lang),
                      time: formatMinutes(stops[i].arrival ?? stops[i].departure),
                      passed: i < pos.progress ||
                          pos.phase == TrainPhase.finished,
                      highlight: i == run.boardIndex || i == run.alightIndex,
                      label: i == run.boardIndex
                          ? l.youBoardHere
                          : i == run.alightIndex
                              ? l.youGetOffHere
                              : null,
                      color: trainColor,
                    ),
                  ),
                if (pos.phase != TrainPhase.finished)
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: pos.progress),
                    duration: Duration(milliseconds: reducedMotion ? 0 : 900),
                    curve: Curves.easeInOut,
                    builder: (_, p, child) => Positioned(
                      left: 19,
                      top: p * rowHeight + rowHeight / 2 - 22,
                      child: child!,
                    ),
                    child: _TrainMarker(pulse: _pulse, color: trainColor),
                  ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.name,
    required this.time,
    required this.passed,
    required this.highlight,
    required this.label,
    required this.color,
  });

  final String name;
  final String time;
  final bool passed;
  final bool highlight;
  final String? label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Row(children: [
      SizedBox(
        width: 82,
        child: Center(
          child: Container(
            width: highlight ? 20 : 14,
            height: highlight ? 20 : 14,
            decoration: BoxDecoration(
              color: passed ? color : scheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
            ),
          ),
        ),
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: (highlight ? text.titleMedium : text.bodyLarge)?.copyWith(
                    fontWeight: highlight ? FontWeight.w700 : null,
                    color: passed && !highlight ? scheme.outline : null)),
            if (label != null)
              Text(label!, style: text.labelSmall?.copyWith(color: color)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Text(time,
            style: text.titleSmall?.copyWith(
                color: passed ? scheme.outline : null,
                fontFeatures: const [FontFeature.tabularFigures()])),
      ),
    ]);
  }
}

class _TrainMarker extends StatelessWidget {
  const _TrainMarker({required this.pulse, required this.color});
  final Animation<double> pulse;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 44,
        height: 44,
        child: AnimatedBuilder(
          animation: pulse,
          builder: (_, child) => Stack(alignment: Alignment.center, children: [
            Container(
              width: 24 + 20 * pulse.value,
              height: 24 + 20 * pulse.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.35 * (1 - pulse.value)),
              ),
            ),
            child!,
          ]),
          child: Container(
            key: const Key('trainMarker'),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)],
            ),
            child: const Icon(Icons.train, color: Colors.white, size: 18),
          ),
        ),
      );
}
