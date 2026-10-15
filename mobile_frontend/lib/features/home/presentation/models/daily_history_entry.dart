import 'package:flutter/foundation.dart';

@immutable
class DailyHistoryEntry {
  const DailyHistoryEntry({
    required this.day,
    required this.date,
    this.dateIso,
    this.badge,
    this.index,
    this.symptoms = const [],
    this.triggers = const [],
    this.isEmpty = false,
  });

  final String day;
  final String date;
  final String? dateIso;
  final String? badge;
  final int? index;
  final List<String> symptoms;
  final List<String> triggers;
  final bool isEmpty;
}
