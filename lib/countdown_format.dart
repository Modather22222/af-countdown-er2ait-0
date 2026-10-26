import 'package:flutter/material.dart';

class CountdownParts {
  const CountdownParts({
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  factory CountdownParts.from(DateTime target, DateTime now) {
    final rawSeconds = target.difference(now).inSeconds;
    final totalSeconds = rawSeconds < 0 ? 0 : rawSeconds;

    return CountdownParts(
      days: totalSeconds ~/ 86400,
      hours: (totalSeconds % 86400) ~/ 3600,
      minutes: (totalSeconds % 3600) ~/ 60,
      seconds: totalSeconds % 60,
    );
  }

  final int days;
  final int hours;
  final int minutes;
  final int seconds;
}

String countdownTimeLabel(BuildContext context, DateTime target) {
  final localizations = MaterialLocalizations.of(context);
  final time = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(target),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );
  final daysFromToday = DateUtils.dateOnly(
    target,
  ).difference(DateUtils.dateOnly(DateTime.now())).inDays;

  switch (daysFromToday) {
    case 0:
      return 'Today · $time';
    case 1:
      return 'Tomorrow · $time';
    case -1:
      return 'Yesterday · $time';
    default:
      return '${localizations.formatMediumDate(target)} · $time';
  }
}
