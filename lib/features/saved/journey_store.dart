import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/settings_controller.dart';

class SavedJourney {
  const SavedJourney(this.fromId, this.toId);

  factory SavedJourney.fromJson(Map<String, dynamic> j) =>
      SavedJourney(j['from'] as String, j['to'] as String);

  final String fromId;
  final String toId;

  Map<String, dynamic> toJson() => {'from': fromId, 'to': toId};

  @override
  bool operator ==(Object other) =>
      other is SavedJourney && other.fromId == fromId && other.toId == toId;
  @override
  int get hashCode => Object.hash(fromId, toId);
}

class JourneyLists {
  const JourneyLists({this.saved = const [], this.recent = const []});
  final List<SavedJourney> saved;
  final List<SavedJourney> recent;
}

/// Saved and recent journeys, kept on the phone so they work offline.
/// (Syncing saved routes to the account comes with the SavedRoutes API.)
class JourneyStore extends Notifier<JourneyLists> {
  static const _kSaved = 'journeys.saved';
  static const _kRecent = 'journeys.recent';
  static const maxRecent = 8;

  List<SavedJourney> _read(String key) {
    final raw = ref.read(sharedPreferencesProvider).getString(key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => SavedJourney.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } on Object {
      return const [];
    }
  }

  Future<void> _write(String key, List<SavedJourney> list) => ref
      .read(sharedPreferencesProvider)
      .setString(key, jsonEncode(list.map((e) => e.toJson()).toList()));

  @override
  JourneyLists build() =>
      JourneyLists(saved: _read(_kSaved), recent: _read(_kRecent));

  bool isSaved(SavedJourney j) => state.saved.contains(j);

  Future<void> toggleSaved(SavedJourney j) async {
    final next = [...state.saved];
    next.contains(j) ? next.remove(j) : next.insert(0, j);
    state = JourneyLists(saved: next, recent: state.recent);
    await _write(_kSaved, next);
  }

  Future<void> addRecent(SavedJourney j) async {
    final next = [j, ...state.recent.where((e) => e != j)].take(maxRecent).toList();
    state = JourneyLists(saved: state.saved, recent: next);
    await _write(_kRecent, next);
  }
}

final journeyStoreProvider =
    NotifierProvider<JourneyStore, JourneyLists>(JourneyStore.new);
